module BrandurOrg
  class Talks < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    helpers do
      def pjax?
        !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
      end
    end

    get "/talks" do
      @title = "Talks"
      slim :talks, layout: !pjax?
    end
  end
end
