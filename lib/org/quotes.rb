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

=begin
    get "/kubla-khan" do
      @title = "Kubla Khan"
      slim :"quotes/kubla-khan"
    end
=end

    get "/lies" do
      @title = "Lies"
      slim :"quotes/lies"
    end
  end
end
