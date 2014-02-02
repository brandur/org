# org

A basic Ruby app that drives my [personal website](http://brandur.org).

## Deploy

```
heroku create org
heroku config:set BLACK_SWAN_DATABASE_URL=postgres://
heroku config:set RACK_ENV=production
git push heroku master
```
