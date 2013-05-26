module BrandurOrg
  class Twitter < Sinatra::Base
    get "/twitter" do
      redirect to("http://metrics.brandur.org/twitter")
    end
  end
end
