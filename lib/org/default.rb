module Org
  class Default < Sinatra::Base
    get "/" do
      if json?
        content_type :json
        MultiJson.encode({
          links: [
            { rel: "articles",        href: "#{request.url}articles" },
            { rel: "favors",          href: "#{request.url}favors" },
            { rel: "lies",            href: "#{request.url}lies" },
            { rel: "reading",         href: "#{request.url}reading" },
            { rel: "talks",           href: "#{request.url}talks" },
            { rel: "that-sunny-dome", href: "#{request.url}that-sunny-dome" },
            { rel: "twitter",         href: "#{request.url}twitter" },
          ]
        }, pretty: true)
      else
        redirect to("/articles")
      end
    end

    not_found do
      404
    end

    private

    def json?
      request.preferred_type("application/json", "text/html") ==
        "application/json"
    end
  end
end
