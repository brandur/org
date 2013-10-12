module Org
  class Quotes < Sinatra::Base
    helpers Helpers::Common

    configure do
      set :views, Config.root + "/views"
    end

    before do
      @body_class = "quote"
    end

    before do
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/accidental" do
      @title = "Accidental"
      slim :"quotes/accidental"
    end

    get "/crying" do
      @title = "Crying"
      slim :"quotes/crying"
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
