require 'digest/md5'

module Org
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

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
    end

    helpers do
      def pjax?
        !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
      end
    end

    get "/articles" do
      @title = "Articles"
      @articles = @@articles.values
      @articles.select! { |a| a[:published_at] <= Time.now }
      @articles += mutelight_articles
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      slim :articles, layout: !pjax?
    end

    get "/articles.atom" do
      @articles = @@articles.values
      @articles.select! { |a| a[:published_at] <= Time.now }
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      builder :articles
    end

    article "/request-ids", {
      hook: <<-eos,
A simple pattern for tracing requests across a service-oriented architecture by injecting a UUID into the events that they produce.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Jun  2 10:21:43 PDT 2013"),
      title:        "Tracing Request IDs",
    } do
      render_article do
        slim :"articles/generic", layout: !pjax?
      end
    end

    article "/service-stubs", {
      hook: <<-eos,
How we build minimal, platform deployable, Rack service stubs to take the pain out of developing applications that depend on an extensive service-oriented architecture.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Jun  3 10:22:11 PDT 2013"),
      title:        "SOA and Service Stubs",
    } do
      render_article do
        slim :"articles/generic", layout: !pjax?
      end
    end

    private

    def log(action, data={}, &block)
      data.merge!({
        app:        "brandur-org",
        request_id: env["REQUEST_IDS"],
      })
      Slides.log(action, data, &block)
    end

    def mutelight_articles
      SimpleCache.get(:mutelight_articles, Time.now + 60) do
        begin
          log :caching, key: :mutelight_articles
          res = Excon.get("#{Config.events_url}/events",
            expects: 200,
            headers: { "Accept" => "application/json" },
            query: { "type" => "blog" })
          MultiJson.decode(res.body).map { |article|
            {
              published_at: Time.parse(article["occurred_at"]),
              slug:         article["slug"],
              source:       "Mutelight",
              title:        article["content"],
            }
          }
        rescue Excon::Errors::Error
          []
        end
      end
    end

    def render_article
      @article = @@articles[request.path_info]
      halt(404) unless @article[:published_at] <= Time.now
      last_modified(@article[:last_modified_at]) if Config.production?
      @title = @article[:title]
      content = yield
      etag(Digest::SHA1.hexdigest(content)) if Config.production?
      content
    end
  end
end
