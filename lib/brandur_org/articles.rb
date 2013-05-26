require 'digest/md5'

module BrandurOrg
  class Articles < Sinatra::Base
    @@articles = {}

    def self.article(route, metadata={}, &block)
      slug = route.gsub(/^\/*/, "")
      metadata.merge!({
        last_modified_at: Time.now,
        slug: slug,
      })
      @@articles[route] = metadata
      get(route, &block)
    end

    def pjax?
      !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
    end

    def render_article
      @article = @@articles[request.path_info]
      last_modified(@article[:last_modified_at]) if Config.production?
      @title = @article[:title]
      content = yield
      etag(Digest::SHA1.hexdigest(content)) if Config.production?
      content
    end

    configure do
      set :views, Config.root + "/views"
    end

    get "/articles" do
      @title = "Articles"
      @articles = @@articles.values.sort_by { |a| a[:published_at] }.reverse
      slim :articles
    end

    article "/service-stubs", {
      location:     "San Francisco",
      published_at: Time.parse("2013-04-19T07:46:40-07:00"),
      title:        "SOA and Service Stubs",
    } do
      render_article do
        slim :"articles/service-stubs", layout: !pjax?
      end
    end

    article "/the-old-man", {
      location:     "San Francisco",
      published_at: Time.parse("2013-04-19T07:46:40-07:00"),
      title:        "The Old Man",
    } do
      render_article do
        slim :"articles/the-old-man", layout: !pjax?
      end
    end
  end
end
