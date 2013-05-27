module BrandurOrg
  Main = Rack::Builder.new do
    use Rack::SSL if Config.force_ssl?
    use Rack::Instruments, app: "brandur-org"
    use Rack::Deflater
    use Rack::Robots

    run Sinatra::Router.new {
      mount BrandurOrg::Articles
      mount BrandurOrg::Assets
      mount BrandurOrg::Books
      mount BrandurOrg::Talks
      mount BrandurOrg::Twitter
      run BrandurOrg::Default
    }
  end
end
