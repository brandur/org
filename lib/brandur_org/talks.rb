module BrandurOrg
  class Talks < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    get "/talks" do
      @title = "Talks"
      slim :talks
    end
  end
end
