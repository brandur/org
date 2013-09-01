module Org
  class Talks < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    helpers Helpers::Common

    get "/talks" do
      @title = "Talks"
      slim :talks, layout: !pjax?
    end
  end
end
