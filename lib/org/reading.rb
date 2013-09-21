module Org
  class Reading < Sinatra::Base
    get "/books" do
      redirect to("https://metrics.brandur.org/reading")
    end

    get "/reading" do
      redirect to("https://metrics.brandur.org/reading")
    end
  end
end
