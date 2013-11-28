module Org
  class Href < Sinatra::Base
    get "/href" do
      redirect to("https://metrics.brandur.org/href")
    end
  end
end
