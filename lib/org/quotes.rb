module Org
  class Quotes < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    before do
      @body_class = "quote"
    end

    get "/favors" do
      @title = "Favors"
      slim :"quotes/favors"
    end

    get "/that-sunny-dome" do
      @title = "Kubla Khan"
      slim :"quotes/that-sunny-dome"
    end

    get "/lies" do
      @title = "Lies"
      slim :"quotes/lies"
    end
  end
end
