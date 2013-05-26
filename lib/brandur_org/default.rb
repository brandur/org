module BrandurOrg
  class Default < Sinatra::Base
    get "/" do
      redirect to("/articles")
    end

    not_found do
      404
    end
  end
end
