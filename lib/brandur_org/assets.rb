module BrandurOrg
  class Assets < Sinatra::Base
    def initialize(*args)
      super
      path = "#{Config.root}/assets"
      @assets = Sprockets::Environment.new do |env|
        Slides.log :assets, path: path

        env.append_path(path + "/fonts")
        env.append_path(path + "/images")
        env.append_path(path + "/javascripts")
        env.append_path(path + "/stylesheets")

        if Config.production?
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      end
    end

    get "/assets/:release/app.css" do
      content_type("text/css")
      respond_with_asset(@assets["app.css"])
    end

    get "/assets/:release/app.js" do
      content_type("application/javascript")
      respond_with_asset(@assets["app.js"])
    end

    %w{jpg png}.each do |format|
      get "/assets/:image.#{format}" do |image|
        content_type("image/#{format}")
        respond_with_asset(@assets["#{image}.#{format}"])
      end
    end

    %w{woff}.each do |format|
      get "/assets/:font.#{format}" do |font|
        content_type("font/#{format}")
        respond_with_asset(@assets["#{font}.#{format}"])
      end
    end

    private

    def respond_with_asset(asset)
      cache_control(:public, max_age: 2592000)
      last_modified(asset.mtime.utc) if Config.production?
      asset
    end
  end
end
