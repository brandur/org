module Org
  class Photos < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    helpers Helpers::Common

    get "/photos" do
      @title = "Photos"
      @photos = DB[:events].reverse_order(:occurred_at).filter(type: "flickr").
        filter("metadata -> 'medium_width' = '500'")
      slim :"photos/index"
    end

    get "/photos/:id" do |id|
      @photo = DB[:events].first(slug: id, type: "flickr") || halt(404)
      @title = @photo[:title] || "Photo #{id}"
      slim :"photos/show"
    end
  end
end
