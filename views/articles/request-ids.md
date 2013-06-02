Traditionally, and like many companies, we've followed the common Rails convention of keeping our API coupled to our web components in what other companies have called their "MonoRail", but what we've always referred to fondly as _Core_. Almost a year ago, we started to split out the brunt of our web views into a project called [Dashboard](https://dashboard.heroku.com), and which today has become the de facto way of managing Heroku accounts and apps online.

More recently, being strong believers in this [SOA] pattern of collapsing larger applications into smaller ones that have a strong sense of purpose and do their particular job very well, we broke out even more of Core's remaining web views into a project called [ID](https://id.heroku.com) that provides management of a Heroku identity including signup, login, password reset, and OAuth 2 compatible endpoints. Like Dashboard, ID delegates its heavy lifting to the (now much more trim) Core that provides the platform's underpinning API.

This pattern has had the benefits of faster development, smaller and more focused teams on each individual project, and more manageable codebases, but as a side effect increased the complexity of debugging any given user action that could interact with a number of services in our backend. For example, a user who isn't logged in and who makes a request to Dashboard will have supporting requests routed through both ID and API on their behalf. How does an operator track what's going on across so many distributed components?

## Request IDs

Based on the same ideas the [request IDs that Amazon uses for route 53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/ResponseHeader_RequestID.html), the request ID is a way of grouping all the information associated with a given request, even as that request makes its way across a distributed architecture. The benefits are two-fold:

* Provides a tagging mechanism for events produced by the system, so that a full report of what occurred in every component of the system can be generated.
* Exposes an identifier to users, both internal and external, which can be used to track down specific issues that they're running into.

In practice, the request ID is a UUID that's generated at the beginning of a request and stored for its duration. Here's a simple Rack middleware that does this job:

``` ruby
class Middleware::Instruments
  def initialize(app)
    @app = app
  end

  def call(env)
    env["REQUEST_ID"] = SecureRandom.uuid
    @app.call(env)
  end
end
```

Logging events in the main app include this identifier in their associated data. A sample helper for Sinatra might look like:

``` ruby
def log(action, data={})
  data.merge!(request_id: request.env["REQUEST_ID"])
  ...
end
```

And with everything done right, a request emits a nice logging stream with each event tagged with the generated request ID:

```
app=api authenticate elapsed=0.001 request_id=9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
app=api rate_limit elapsed=0.001 request_id=9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
app=api provision_token elapsed=0.003 request_id=9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
app=api serialize elapsed=0.000 request_id=9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
app=api response status=201 elapsed=0.005 request_id=9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
```

Our apps are all configured to drain their log streams to Splunk, which provides a centralized location that allows us to query for all information associated with a given request ID:

```
9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
```

## Heroku's Request IDs

Heroku's routing layer can [generate a request ID]() automatically, which allows platform-generated logging events to be tagged in as well. Rather than generating them yourself, these IDs can be accessed through an incoming header:

``` ruby
def log(action, data={})
  data.merge!(request_id: request.env["HTTP_HEROKU_REQUEST_ID"])
  ...
end
```

## Composing Request IDs

Request IDs provide a convenient mechanism for digging into a single request for any given app, but so far they're not much help when it comes to a number of composed apps that are constantly making calls to each other.

We take the concept a step further by having apps that make calls to other apps inject their own request ID via a request header.

``` ruby
api = Excon.new("https://api.heroku.com", headers: {
  "Request-ID" => request.env["REQUEST_ID"]
})
api.post("/oauth/tokens", expects: 201)
```

The callee in turn accepts a request ID, and if it looks like a valid identifier, tags all its requests with the given request ID _as well as_ one that it generates itself. This way we can make sure that a request across many apps can be tracked as a group, but each app always has a way of tracking every one of its requests invidually too.

``` ruby
def call(env)
  env["REQUEST_ID"] = SecureRandom.uuid
  if env["HTTP_REQUEST_ID"] =~ UUID_PATTERN
    env["REQUEST_ID"] += "," + env["HTTP_REQUEST_ID"]
  end
  @app.call(env)
end
```

The event stream emmitted by the composed apps is now tagged based on all generated request IDs:

```
app=id session_check elapsed=0.000 request_id=4edef22b...
app=api authenticate elapsed=0.001 request_id=9d5ccdbe...,4edef22b...
app=api rate_limit elapsed=0.001 request_id=9d5ccdbe...,4edef22b...
app=api provision_token elapsed=0.003 request_id=9d5ccdbe...,4edef22b...
app=api serialize elapsed=0.000 request_id=9d5ccdbe...,4edef22b...
app=api response status=201 elapsed=0.005 request_id=9d5ccdbe...,4edef22b...
app=id response status=200 elapsed=0.010 request_id=4edef22b...
```

A Splunk query based on the top-level request ID will yield logging events from all composed apps. Note that although we use Splunk here, alternatives like Papertrail will do the same job.

<div class="attachment"><img src="/assets/request-ids/splunk-search.png"></div>

## Tweaks

### Inject Any Number of Request IDs

A minor modification to the middleware pattern above will allow any number of request IDs to be injected into a given app, so that a request can be traced across three or more composed services.

``` ruby
def call(env)
  env["REQUEST_ID"] = SecureRandom.uuid
  if env["HTTP_REQUEST_ID"]
    request_ids = env["HTTP_REQUEST_ID"].split(",").
      select { |id| id =~ UUID_PATTERN }
    env["REQUEST_ID"] = (env["REQUEST_ID"] + request_ids).join(",")
  end
  @app.call(env)
end
```

### Respond with Request ID

The request ID can be returned as a response header to enable easier identification and subsequent debugging of any given request:

``` ruby
def call(env)
  request_id = SecureRandom.uuid
  ...
  status, headers, response = @app.call(env)
  headers["Request-ID"] = request_id
  [status, headers, response]
end
```

```
curl -i https://api.example.com/hello
...
Request-ID: 9d5ccdbe-6a5c-4da7-8762-8fb627a020a4
...
```

Heroku's new [V3 platform API]() includes a request ID in the respones with every request.

### Storing Request ID in a Request Store

In a larger application, producing logs from a context-sensitive method like a Sinatra helper may be architecturally difficult. In cases like this, a thread-safe request store pattern can be used instead.

``` ruby
# request store that keys a hash to the current thread
module RequestStore
  def self.store
    Thread.current[:request_store] ||= {}
  end
end

# middleware that initializes a request store and and adds a request ID to it
class Middleware::Instruments
  ...

  def call(env)
    RequestStore.store.clear
    RequestStore.store[:request_id] = SecureRandom.uuid
    @app.call(env)
  end
end

# class method that can extract a request ID and tag logging events with it
module Log
  def self.log(action, data={})
    data.merge!(request_id: RequestStore.store[:request_id])
    ...
  end
end
```
