module Org
  class Twitter < Sinatra::Base
    get "/twitter" do
      redirect to("https://metrics.brandur.org/twitter")
    end
  end
end
