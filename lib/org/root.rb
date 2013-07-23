module Org
  class Root < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    helpers do
      def pjax?
        !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
      end
    end

    get "/" do
      @title = "brandur.org"
      slim :root, layout: !pjax?
    end
  end
end
