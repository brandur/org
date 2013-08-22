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
      @photos = DB[:events].reverse_order(:occurred_at).filter(type: "flickr").
        filter("metadata -> 'medium_width' = '500'").limit(5)
      slim :photos
    end
  end
end
