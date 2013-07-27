module Org
  Main = Rack::Builder.new do
    use Rack::SSL if Config.force_ssl?
    use Rack::Instruments, app: "brandur-org"
    use Rack::Deflater
    use Rack::Robots

    run Sinatra::Router.new {
      mount Org::Articles
      mount Org::Assets
      mount Org::Humans
      mount Org::Quotes
      mount Org::Reading
      mount Org::Talks
      mount Org::Twitter
      run Org::Default
    }
  end
end
