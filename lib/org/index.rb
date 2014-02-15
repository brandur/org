module Org
  class Index < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Reading
    helpers Helpers::Twitter

    before do
      log :access_info, pjax: pjax?
    end

    configure do
      set :views, Config.root + "/views"
    end

    get "/" do
      # don't cache without revalidation from server (used because this method
      # returns content based on accept header)
      cache_control :no_cache
      if json?
        content_type :json
        etag(Digest::SHA1.hexdigest("index-map"))
        MultiJson.encode({
          links: [
            { rel: "accidental",      href: "#{request.url}accidental" },
            { rel: "articles",        href: "#{request.url}articles" },
            { rel: "crying",          href: "#{request.url}crying" },
            { rel: "favors",          href: "#{request.url}favors" },
            { rel: "humans",          href: "#{request.url}humans.txt" },
            { rel: "lies",            href: "#{request.url}lies" },
            { rel: "photos",          href: "#{request.url}photos" },
            { rel: "reading",         href: "#{request.url}reading" },
            { rel: "talks",           href: "#{request.url}talks" },
            { rel: "that-sunny-dome", href: "#{request.url}that-sunny-dome" },
            { rel: "tenets",          href: "#{request.url}tenets" },
            { rel: "twitter",         href: "#{request.url}twitter" },
          ]
        }, pretty: true)
      else
        events = DB[:events].reverse_order(:occurred_at)
        @essays   = Articles.articles
        @photos   = events.filter(type: "flickr").
          filter("metadata -> 'medium_width' = '500'").limit(18)
        slugs = [@essays.first, @photos.first].
          map { |e| e[:slug] }.
          join("-")
        etag(Digest::SHA1.hexdigest("index-#{slugs}"))
        @viewport_width = "600"
        slim :"index"
      end
    end

    private

    def json?
      request.preferred_type("application/json", "text/html") ==
        "application/json"
    end
  end
end
