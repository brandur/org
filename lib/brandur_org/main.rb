module BrandurOrg
  Main = Rack::Builder.new do
    use Rack::SSL if Config.force_ssl?
    use Rack::Instruments
    use Rack::Deflater
    use Rack::Robots

    run Sinatra::Router.new {
      mount BrandurOrg::Articles
      mount BrandurOrg::Assets
      run BrandurOrg::Default
    }
  end
end
