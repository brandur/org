module Org
  class About < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    helpers Helpers::Common

    get "/about" do
      @title = "About"
      slim :about, layout: !pjax?
    end
  end
end
