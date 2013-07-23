module Org
  class Reading < Sinatra::Base
    get "/reading" do
      redirect to("https://metrics.brandur.org/reading")
    end
  end
end
