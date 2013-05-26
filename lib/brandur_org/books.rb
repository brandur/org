module BrandurOrg
  class Books < Sinatra::Base
    get "/books" do
      redirect to("http://metrics.brandur.org/books")
    end
  end
end
