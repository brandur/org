

```
  url = env!("BLACK_SWAN_DATABASE_URL")
  if RUBY_PLATFORM == 'java'
    url = "jdbc:" + url
  else
    url
  end
```

Puma 2.0 with `-w`:

    ERROR: worker mode not supported on JRuby and Windows

## Heroku

* PATH
* 

heroku config:add PATH="bin:jruby/bin:/usr/bin:/bin"

http://thejspr.com/blog/migrating-a-rails-heroku-app-to-jruby/

* JRUBY_OPTS
* therubyrhino
