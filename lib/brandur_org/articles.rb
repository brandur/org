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
      @articles = @@articles.values.sort_by { |a| a[:published_at] }.reverse
      res = Excon.get("#{Config.events_url}/events",
        expects: 200,
        headers: { "Accept" => "application/json" },
        query: { "type" => "blog" })
      @articles += MultiJson.decode(res.body).map { |article|
        {
          published_at: Time.parse(article["occurred_at"]),
          slug:         article["slug"],
          source:       "Mutelight",
          title:        article["content"],
        }
      }
      slim :articles, layout: !pjax?
    end

    get "/articles.atom" do
      @articles = @@articles.values.sort_by { |a| a[:published_at] }.reverse
      builder :articles
    end

    article "/request-ids", {
      hook: <<-eos,
We use a simple pattern to track any given request by injecting a particular key into all the logging events that it produces.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sat May 25 20:49:02 PDT 2013"),
      title:        "Request IDs",
    } do
      render_article do
        slim :"articles/generic", layout: !pjax?
      end
    end

    article "/service-stubs", {
      hook: <<-eos,
How we take the pain out of developing for service-oriented architecture and keep development on every project fast and efficient.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sat May 25 20:49:02 PDT 2013"),
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

    def render_article
      @article = @@articles[request.path_info]
      last_modified(@article[:last_modified_at]) if Config.production?
      @title = @article[:title]
      content = yield
      etag(Digest::SHA1.hexdigest(content)) if Config.production?
      content
    end
  end
end
