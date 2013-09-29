module Org
  class Tenets < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    before do
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/tenets" do
      slim :"tenets"
    end
  end
end
