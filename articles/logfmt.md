If you've ever run an app on Heroku, you may have come across log messages produced by the Heroku router and wondered about their untraditional formatting:

    at=info method=GET path=/ host=mutelight.org fwd="124.133.52.161"
      dyno=web.2 connect=4ms service=8ms status=200 bytes=1653

This curious format is unofficially known as "logfmt", and at Heroku we've adopted it as a standard to provide some consistency across internal components. I've never been able to find any good posts providing any context or background for logfmt, so I thought I'd do a short write-up.

At its core, logfmt is just a basic way of displaying key/value pairs in such a way that its output is fairly easily readable by a human or a computer, while at the same time not being absolutely optimal for either.

Especially with a bit of practice and colorized output, it's pretty easy for a human being to see what's going on here which is of course a core value for any good logging format. At the same time, building a machine parser for the format is trivial so any of our internal components can ingest logs produced by any other component. [Splunk also recommends the same format under their best practices](http://dev.splunk.com/view/logging-best-practices/SP-CAAADP6) so we can be sure that it can be used to search and analyze all our logs in the long term.

A few projects from Heroku employees already exist to help parse logfmt in various languages:

* [logfmt for Clojure](https://github.com/tcrayford/logfmt)
* [logfmt for Go](http://godoc.org/github.com/kr/logfmt)
* [logfmt for Node.JS](https://github.com/csquared/node-logfmt)
* [logfmt for Python](https://pypi.python.org/pypi/logfmt/0.1)
* [logfmt for Ruby](https://github.com/cyberdelia/logfmt-ruby)

## Eliminate the Guesswork (#eliminate-guesswork)

A major advantage provided by logfmt is that it helps to completely eliminate any guesswork that a developer would have to make while deciding what to log. Take the following line in a more traditional logging format for example:

    INFO [ConsumerFetcherManager-1382721708341] Stopping all fetchers
      (kafka.consumer.ConsumerFetcherManager)

While writing this code, a developer would've had to decide how to format the log line like placing the manager's identifier in square brackets at the beginning, the module name in parenthesis at the end, with some general information in the middle. Convention can help a lot here, but it's still something that a developer has to think about it. Furthermore, what if they want to add another piece of data like number of open fetchers? Does that belong on a new line, or in another set of brackets somewhere?

An equivalent logfmt line might look this:

    level=info stopping_fetchers id=ConsumerFetcherManager-1382721708341
      module=kafka.consumer.ConsumerFetcherManager

Readability isn't compromised too much, and all the developer has to do is dump any information that they think is important. Adding another piece of data is no different, just append `num_open_fetchers=3` to the end. The developer also knows that if for any reason they need to generate a statistic on-the-fly like the average number of fetchers still open, they'll easily be able to do that with a simple Splunk (or equivalent) query:

    stopping_fetchers | stats p50(num_open_fetchers) p95(num_open_fetchers)
      p99(num_open_fetchers)

## Building Context (#building-context)

logfmt also lends itself well to building context around operations. Inside a request for example, as important information becomes available, it can be added to a request-specific context and included with every log line published by the app. This may not seem immediately useful, but it can be very helpful while debugging in production later, as only a single log line need be found to get a good idea of what's going on.

For instance, consider this simple Sinatra app:

``` ruby
def authenticate!
  @user = User.authenticate!(env["HTTP_AUTHORIZATION"]) || throw(401)
  log_context.merge! user: @user.email, user_id: @user.id
end

def find_app
  @app = App.find!(params[:id])
  log_context.merge! app: @app.name, app_id: @app.id
end

before do
  log request: true, at: "start"
end

get "/:id" do
  authenticate!
  find_app!
end

after do
  log request: true, at: "finish", status: response.status
end

error do
  e = env["sinatra.error"]
  log error: true, class: e.class.name, message: e.message
end
```

Typical logging produced as part of a request might look like this:

    request at=start
    request at=finish status=200 user=brandur@mutelight.org user_id=1234
      app=mutelight app_id=1234

The value becomes even more apparent when we consider what would be logged on an error, which automatically contains some key information to help with debugging (note that in real life, we'd include a stack trace as well):

    error class=NoMethodError message="undefined method `serialize' for nil:NilClass"
      user=brandur@mutelight.org user_id=1234 app=mutelight app_id=1234
