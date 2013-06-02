module Org
  class Books < Sinatra::Base
    get "/books" do
      redirect to("https://metrics.brandur.org/books")
    end
  end
end
