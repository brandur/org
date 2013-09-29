module Org
  class About < Sinatra::Base
    helpers Helpers::Common

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/about" do
      @title = "About"
      slim :about, layout: !pjax?
    end
  end
end
