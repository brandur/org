module Org
  class Default < Sinatra::Base
    configure do
      set :views, Config.root + "/views"
    end

    helpers Helpers::Common
    helpers Helpers::Goodreads
    helpers Helpers::Twitter

    get "/" do
      if json?
        content_type :json
        MultiJson.encode({
          links: [
            { rel: "articles",        href: "#{request.url}articles" },
            { rel: "favors",          href: "#{request.url}favors" },
            { rel: "humans",          href: "#{request.url}humans.txt" },
            { rel: "lies",            href: "#{request.url}lies" },
            { rel: "reading",         href: "#{request.url}reading" },
            { rel: "talks",           href: "#{request.url}talks" },
            { rel: "that-sunny-dome", href: "#{request.url}that-sunny-dome" },
            { rel: "twitter",         href: "#{request.url}twitter" },
          ]
        }, pretty: true)
      else
        @body_class = "index"
        @books    = BlackSwanClient.new.get_events("goodreads")
        @essays   = Articles.articles
        @links    = BlackSwanClient.new.get_events("readability")
        @photos   = BlackSwanClient.new.get_events("flickr", limit: 15).
          reject { |p| p["metadata"]["medium_width"] != "500" }[0, 5]
        @tweets   = BlackSwanClient.new.get_events("twitter", limit: 30).
          reject { |t| t["metadata"]["reply"] == "true" }[0, 10]
        slim :"index"
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
