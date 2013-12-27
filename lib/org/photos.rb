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
      @viewport_width = "1100"
      slim :"photos/show"
    end

    get "/photos/large/:id.jpg" do |id|
      send_photo(id, "large_image")
    end

    get "/photos/medium/:id@2x.:extension" do |id, _|
      send_photo(id, "large_image")
    end

    get "/photos/medium/:id.:extension" do |id, _|
      send_photo(id, "medium_image")
    end

    private

    def send_photo(id, key)
      @photo = DB[:events].first(slug: id, type: "flickr") || halt(404)
      res = Excon.get(@photo[:metadata][key], expects: 200)
      content_type(res.headers["Content-Type"])
      res.body
    end
  end
end
