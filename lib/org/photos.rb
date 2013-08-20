module Org
  class Photos < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
    end

    helpers Helpers::Common

    get "/photos" do
      @title = "Photos"
      @photos = cache(:photos) {
        BlackSwanClient.new.get_events("flickr", limit: 100).
          reject { |p| p["metadata"]["medium_width"] != "500" }
      }
      slim :photos
    end
  end
end
