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
      slim :articles, layout: !pjax?
    end

    get "/articles.atom" do
      @articles = @@articles.values.sort_by { |a| a[:published_at] }.reverse
      builder :articles
    end

    article "/service-stubs", {
      location:     "San Francisco",
      published_at: Time.parse("Sat May 25 20:49:02 PDT 2013"),
      title:        "SOA and Service Stubs",
    } do
      render_article do
        slim :"articles/generic", layout: !pjax?
      end
    end
  end
end
