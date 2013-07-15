## Expectations



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

## Instrumentation

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
      headers: {
        "Accept"     => "application/json",
        "Request-Id" => RequestStore.request_id,
      },
      instrumentor: ExconInstrumentor.new(service: "widgets"))
    end
  end

  ...
end
```

### Metrics

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
    Sample.measure "widgets.requests"
    Sample.measure "widgets.latency" do
      yield
    end
  rescue Excon::Errors::HTTPStatusError => e
    Sample.measure "widgets.errors.#{e.response.status}"
    Sample.measure "widgets.errors"
    raise
  rescue *ApiError::HttpExceptions
    Sample.measure "widgets.errors"
    Sample.measure "widgets.resets"
    raise
  end
end
```

## Idempotence

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
  rescue *ApiError::HttpExceptions
    Sample.measure "widgets.errors"
    Sample.measure "widgets.resets"
    # reset on connection errors, but not HTTP status errors
    @api.reset
    raise
  end
end
```

## I Don't Want Your Client Library
