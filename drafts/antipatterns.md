In [Tracing Request IDs](/request-ids), I briefly talked about the possibility of making a request ID easily available from anywhere in an app through a pattern known as the _request store_. The request store is a very simple construct that stores data into Ruby's thread-local context:

``` ruby
# request store that keys a hash to the current thread
module RequestStore
  def self.store
    Thread.current[:request_store] ||= {}
  end
end
```

A simple middleware is then inserted into the app which makes sure that all context that was added to the store is cleared between requests:

``` ruby
class Middleware::RequestStore
  ...

  def call(env)
    ::RequestStore.store.clear
    @app.call(env)
  end
end
```

In a larger application, it's been my habit to extend the original pattern a bit so that we inventory exactly what's supposed to be in there, and makes it more difficult to create opaque dependencies by mixing data in randomly:

``` ruby
module RequestStore
  def log_context ; store[:log_context] ; end
  def request_id  ; store[:request_id]  ; end

  def log_context=(val) ; store[:log_context] = val ; end
  def request_id =(val) ; store[:request_id]  = val ; end

  private

  def self.store
    Thread.current[:request_store] ||= {}
  end
end
```

## The Anti-pattern

The request store is an anti-pattern. Much like the infamous [singleton pattern](http://en.wikipedia.org/wiki/Singleton_pattern), it introduces global state state into its application which in turn makes it more difficult to reason about the dependencies of any given piece of code. Global state can have other side effects too, like making testing more difficult. Globals that initialize themselves implicitly can be hard to set without a great stubbing framework, and will undesirably keep their value across multiple test cases.

This sort of technique is slightly less controversial in the world of dynamic languages, but I think it's safe to say that my highly pattern-oriented colleagues back in the enterprise world would have chastised me for considering the use of global state.

Despite all this, from an engineering perspective the side effects of using the request store over time have been surprisingly minimal. By staying vigilant in making sure that it doesn't creep beyond its originally intended use, the request store becomes a very convenient way to store a few pieces of global state that would otherwise be very awkward to access. It's a fine line though, and it would be easy enough to let abuse seep into the system if members of the team didn't keep each other in check.

Request store isn't an isolated case either. Projects like Rails and Sinatra have been using singleton patterns in places like [managing their database connection](https://github.com/rails/rails/blob/4-0-stable/activerecord/lib/active_record/core.rb#L86-L88) or [delegating DSL methods from the main module](https://github.com/sinatra/sinatra/blob/184fe58ca5879d04fce82fcb190c10f72e1f63bc/lib/sinatra/base.rb#L1988) for years. These uses have probably not been completely painless over the years, but lasting as long as they have is a testament to their success at least on a practical level.
