module Org
  Main = Rack::Builder.new do
    use Rack::SSL if Config.force_ssl?
    use Org::Instruments
    use Rack::Deflater
    use Rack::Cache,
      verbose:     true,
      metastore:   'file:/tmp/cache/meta',
      entitystore: 'file:/tmp/cache/entity' if Config.production?
    use Rack::Robots

    run Sinatra::Router.new {
      mount Org::About
      mount Org::Articles
      mount Org::Assets
      mount Org::Humans
      mount Org::Index
      mount Org::Photos
      mount Org::Quotes
      mount Org::Reading
      mount Org::Talks
      mount Org::Tenets
      mount Org::Twitter
      run Org::Default
    }
  end
end
