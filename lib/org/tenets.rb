module Org
  class Tenets < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    get "/tenets" do
      slim :"tenets"
    end
  end
end
