When speaking ot a number of backend services in a SOA formation, it's helpful to start developing patterns to ensure that remote interfaces are accessed in a standard way. This is useful so that these services can be monitored in a generic fashion, and as insurance that enough visibility and debugging data is available for any one of them when the time comes where that data is inevitably required.

Our orchestration component speaks to a dozen backend services to help perform the heavy lifting needed to run the platform. I've extracted a few basic Ruby patterns from its client libraries to demonstrate some simple, but powerful ideas that are portable to almost case where an app needs to speak to an HTTP API.

## Expectations

An obvious first step is to understand the contract between your app and the service that it's trying to talk to. What kind of response should you expect on a successful operation? What kind of error responses can you expect on a failure? How should your app handle each type of failure?

My HTTP client library of choice, Excon, has a very powerful mechanism for flow control called the `expects` option. In the example below where we call out to our widget service to create a widget, the code will fall through normally if we get back our expected `201` status code, and an exception will be thrown otherwise.

``` ruby
class WidgetsAPI
  ...

  def create_widget(data)
    @api.post(
      path: "/widgets",
      body: MultiJson.encode(data),
      expects: 201
    )
  end

  ...
end
```

We can rescue exceptions to handle the various error conditions. For example, and assuming that this service is being made synchronously with a request to our own app, we might want to bubble a `422` back up, and respond with a `503` in case of a connection problem.

``` ruby
  def create_widget(data)
    @api.post(
      ...
    )
  rescue Excon::Errors::UnprocessableEntity => e
    raise API::Error.new(422, "Couldn't create widget: #{e.response.body}.")
  rescue Excon::Errors::Error
    raise API::Error.new(503, "Service unavailable.")
  end
```

## Instrumentation

Next up, it's a good idea to introduce some instrumentation into calls out to the service. Whenever a call is made, we should wrap it with some basic logging info to give us a good idea as to what went on inside any given request. In case of an error, we should log as much about it as we possibly can so that the data can be analyzed later. I often include [request IDs](/request-ids) in logging instrumentation so that remote API calls can be matched up to the request that generated them.

Once again, Excon has a simple pattern to help us out here called an instrumentor that gets called out to before and after every request. Better yet, a single instrumentor class can be re-used across all services in an app.

``` ruby
class ExconInstrumentor
  attr_accessor :events

  def initialize(extra_data={})
    @extra_data = extra_data
  end

  def instrument(name, params={}, &block)
    data = {
      action:     name,
      host:       params[:host],
      path:       params[:path],
      method:     params[:method],
      expects:    params[:expects],
      request_id: RequestStore.request_id,
      status:     params[:status],
    }
    # dump everything on an error
    data.merge!(params) if name == "excon.error"
    data.merge!(@extra_data)
    Log(data, &block)
  end
end
```

``` ruby
class WidgetsAPI
  def initialize
    @api = Excon.new(ENV["WIDGETS_URL"],
      instrumentor: ExconInstrumentor.new(service: "widgets"))
    end
  end

  ...
end
```

### Metrics

Expanding on the idea of instrumentation above, logging provides some great detail that can be referenced for single requests as needed, but it's a good idea to start producing metrics from theses calls as well to produce aggregate data that provides a window into a service's health, and which can be monitored easily.

Some of the common metrics to monitor are the service's response time, the number of requests that we're making to it, the number of errors coming back to it, and the errors organized by bucket (`422s`, `500s`, and connection errors).

``` ruby
class WidgetsAPI
  ...

  def create_widget(data)
    request do
      @api.post(
        path: "/widgets",
        body: MultiJson.encode(data),
        expects: 201
      )
    end
  end

  private

  def request
    Sample.count "widgets.requests"
    Sample.measure "widgets.latency" do
      yield
    end
  rescue Excon::Errors::HTTPStatusError => e
    Sample.count "widgets.errors.#{e.response.status}"
    Sample.measure "widgets.errors"
    raise
  rescue Excon::Errors::Error
    Sample.count "widgets.errors"
    raise
  end
end
```

## Idempotence

It's important to understand from the get-go whether or not a particular endpoint is idempotent so that we know whether we can safely retry a request in the event of an error like a connection reset. If it is, then we can retry right away (Excon even has an option for this: `idempotent`), but if it's not, then more complex logic will be required to make sure that the state between the app and service is sane.

``` ruby
class WidgetsAPI
  ...

  def update_widget(id, data)
    request do
      @api.patch(
        path: "/widgets/#{id}",
        expects: 200
        body: MultiJson.encode(data),
        # update is idempotent, retry until this works
        idempotent: true,
      )
    end
  end

  ...
end
```

## Persistent Connections

Establishing new connections, especially secure ones, is expensive and should be avoided as much as possible. A pool pattern can be used to start re-using connections across an app, which will very often result in better and more uniform performance across the board.

Here's a very simple implementation to demonstrate the concept:

``` ruby
class ConnectionPool
  def initialize(&block)
    @block = block
  end

  def conn
    # in a testing environment, always initialize a fresh API
    if ENV["RACK_ENV"] != "test"
      Thread.current["ConnectionPool-#{object_id}"] ||= @block.call
    else
      @block.call
    end
  end
end
```

``` ruby
WidgetsConnPool = ConnectionPool.new { WidgetsAPI.new }
WidgetsConnPool.conn.create_widget({ name: "my-widget" })
```

You may even want to add a new metric here to track how often these connections are being reset, and if not using Excon, possibly some specialized retry logic as well.

``` ruby
class WidgetsAPI
  ...

  def request
    Sample.measure "widgets.requests"
    Sample.measure "widgets.latency" do
      yield
    end
  rescue Excon::Errors::HTTPStatusError => e
    Sample.measure "widgets.errors.#{e.response.status}"
    Sample.measure "widgets.errors"
    raise
  rescue Excon::Errors::Error
    Sample.measure "widgets.errors"
    Sample.measure "widgets.resets"
    # reset on connection errors, but not HTTP status errors
    @api.reset
    raise
  end
end
```

## Alarms

With metrics in place, you may want to add some alarms depending on how critical successful calls to the service are to your app's operation. From the example above, we might want to add an alarm if the `widgets.errors` goes over an unacceptable threshold, which probably indicates that the service is down, or if `widgets.latency` spikes to rates far above normal, which could significantly impact quality of service for the clients of your own app, or result in a more subtle cascading error effect.

## I Don't Want Your Client Library

In the Ruby world, it's a pretty common practice to ship a gem along with your API that provides [easy helpers to consume it](https://github.com/heroku/heroku.rb). In some cases, we've even done this for internal services and I'm occasionally met with surprise when I tell providers that I probably won't use such a thing. This statement may sound somewhat questionable, but the reasoning is fairly simple: HTTP itself already provides a very generic way of accessing any API using it, and by building my own thin layers on top of an HTTP library, I can pull in all the patterns to ensure faster, more reliable, and more transparent communication.
