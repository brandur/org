source "https://rubygems.org"

ruby "2.1.0"
#ruby "2.0.0", engine: "jruby", engine_version: "1.7.4"

gem "builder"
gem "coffee-script"
gem "excon"
gem "multi_json"
gem "puma"
gem "rack"
gem "rack-cache"
gem "rack-robots"
gem "rack-ssl"
gem "sass"
gem "sequel", require: ["sequel", "sequel/extensions/pg_hstore"]
gem "sequel-instruments"
gem "slides"
gem "sinatra", require: "sinatra/base"
gem "sinatra-router"
gem "slim"
gem "sprockets"
gem "uglifier"
gem "yui-compressor"

group :development, :test do
  platform :ruby do
    gem "debugger2"
  end

  gem "rack-test"
  gem "rr"
  gem "turn"
end

platform :jruby do
  gem "gson"
  gem "jdbc-postgres"
  gem "kramdown"
  gem "therubyrhino"
end

platform :ruby do
  gem "oj"
  gem "pg"
  gem "redcarpet"
end
