At Heroku, we're proud of our ability to decompose pieces of our architecture into a number of smaller services that are more easily manageable. Building out this kind of service oriented architecture (**SOA**) has turned out to be a huge win, and has allowed us to operate, develop, and deploy our independent services more quickly and effectively.

One down-side of the approach however, is that it becomes more difficult to run and develop a single service in isolation because it's used to relying on so many cloud dependencies. In a service like Core, the traditional solution was to mock out services at a fairly high level using a variety of mechanisms like the following.

``` ruby
# psmgr
return ServiceApi::MockHandler.new("https://psmgr.heroku-#{name}.com") unless psmgr_url

# shushu
def detect_handler
  return RealHandler.new if ENV.has_key?("CORE_SHUSHU_URL")
  MockHandler.new
end

# maestro
Maestro::ResourceHandler.mock!

# addons
Addons::Client.mock!

# logplex
Logplex.stub(:create_token)
```

Note that some of these lines actually live inside the application code rather than in the test modules to allow Core to run locally in development mode. The sheer variety in the different approaches makes what's actually happening in the backend during a development or test run quite inscrutable without deep knowledge of the system.

## An Alternative Approach

While building out the new API app, I've been experimenting with an alternative approach: building Rack stubs for all foreign services that the API needs to speak to. These stubs are extremely simplistic, and might look something like the following.

``` ruby
class IonStub < Sinatra::Base
  post "/endpoints" do
    status 201
    content_type :json
    MultiJson.encode({
      id:           123,
      cname:        "tokyo-1234.herokussl.com",
      elb_dns_name: "elb016353-1913934129.us-east-1.elb.amazonaws.com",
    })
  end
end
```

As mentioned before, the stub is a fully functional and deployable Rack app. It can and should be used in both development and testing, and by deploying it to the Heroku platform, it can also be applied to staging where it can speak to other platform apps.

## Testing

By using [webmock](https://github.com/bblimke/webmock)'s excellent Rack support, requests can be routed in our tests to the stub. A helper method is defined to help setup the stub during individual tests.

``` ruby
# generic helper for use with any service
def stub_service(uri, stub, &block)
  uri = URI.parse(uri)
  port = uri.port != uri.default_port ? ":#{uri.port}" : ""
  stub = block ? Sinatra.new(stub, &block) : stub
  stub_request(:any, /^#{uri.scheme}:\/\/(.*:.*@)?#{uri.host}#{port}\/.*$/).
    to_rack(stub)
end

# one-liner specifically for use with ion
def stub_ion(&block)
  stub_service(ENV["ION_URL"], IonStub, &block)
end
```

Now the stub can be initialized and a call made that requests the service in its backend.

``` ruby
it "should make a call to ion" do
  stub_ion
  ElbApi.create!
end
```

To test edge cases, particular endpoints on the stub can be overridden using Sinatra's widely-known DSL, and subsequently tested against.

``` ruby
it "should raise an error on a bad ion response" do
  stub_ion do
    post("/endpoints") { 422 }
  end
  lambda do
    ElbApi.create!
  end.should raise_error(ElbApi::Error)
end
```

## Development

We can ensure that any given stub can be run as its own individual service by including a block like the following in its file.

``` ruby
if __FILE__ == $0
  $stdout.sync = $stderr.sync = true
  IonStub.run! port: 4103
end
```

Now we can depend on Sinatra do easily boot the stub simply by invoking its filename.

``` bash
ruby test/test_support/service_stubs/ion_stub.rb
>> Listening on 0.0.0.0:4103, CTRL+C to stop
```

Ensure that the entry in local `.env` files points to the stub on its pre-defined port number.

```
ION_URL=http://localhost:4103
```

Now boot the app the depends on the stubbed service (in this case, API).

``` bash
api(master*) $ foreman start web
21:34:46 web.1            | listening on addr=0.0.0.0:5001 fd=13
```

Finally, a successful call be made against the booted app thanks to the stub. This function would normally only be usable by ensuring the inclusion of credentials for a cloud-based Ion somewhere (or by booting a local Ion which could be an adventure in itself).

``` bash
api(master*) $ curl -i --user :0fc46ba3385b3de55892328a09f2de158b878316 -X POST http://localhost:5001/apps/great-cloud/ssl-endpoints --data-urlencode key@./test/test_support/resources/secure.example.org.key --data-urlencode pem@./test/test_support/resources/secure.example.org.pem
HTTP/1.1 201 Created
Date: Mon, 14 Jan 2013 05:29:06 GMT
Status: 201 Created
Connection: close
X-Frame-Options: sameorigin
X-XSS-Protection: 1; mode=block
Content-Type: application/json;charset=utf-8
X-RateLimit-Limit: 486
X-RateLimit-Remaining: 485
X-RateLimit-Reset: 1358141406
Content-Length: 640
Vary: Accept-Encoding

{
  "cname":"tokyo-1234.herokussl.com",
  "name":"iwate-2136",
  "warnings":[
    [
      "ssl_cert",
      "provides no domain(s) that are configured for this Heroku app"
    ]
  ],
  "ssl_cert":{
    "ca_signed?":false,
    "cert_domains":[
      "secure.example.org",
      "alt1.example.org",
      "alt2.example.org"
    ],
    "expires_at":"2031/05/05 12:05:56 -0700",
    "issuer":"/C=US/ST=California/L=San Francisco/O=Heroku/CN=secure.example.org",
    "self_signed?":true,
    "starts_at":"2011/05/10 12:05:56 -0700",
    "subject":"/C=US/ST=California/L=San Francisco/O=Heroku/CN=secure.example.org"
  },
  "ssl_cert_prev":null}
```

This process could be even more streamlined by adding the stub as a process within a development `Procfile` and calling `foreman start`. This is an even more significant win if _every_ dependent service is included so that one command can bring up a fully-functional app (by my count, API has [at least ten](https://github.com/heroku/api/blob/master/test/test_support/service_stubs.rb) standard dependencies that traditionally have made local development difficult).

### Foreman

```
# proxy should come first so it gets the 5000+ port range
proxy:          bundle exec ruby lib/proxy.rb

web:            bundle exec unicorn -c config/unicorn.rb
eventprocessor: bundle exec bin/eventprocessor

# stubs
eventmanagerstub: bundle exec ruby test/test_support/service_stubs/event_manager_stub.rb
ionstub:          bundle exec ruby test/test_support/service_stubs/ion_stub.rb
psmgrstub:        bundle exec ruby test/test_support/service_stubs/psmgr_stub.rb
yobukostub:       bundle exec ruby test/test_support/service_stubs/yobuko_stub.rb
```
