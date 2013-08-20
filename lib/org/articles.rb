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

    def self.articles
      articles = @@articles.values
      articles.select! { |a| a[:published_at] <= Time.now }
      articles.sort_by! { |a| a[:published_at] }
      articles.reverse!
      articles
    end

    configure do
      set :views, Config.root + "/views"
    end

    helpers Helpers::Common

    before do
      log :access_info, pjax: pjax?
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

    private

    def mutelight_articles
      SimpleCache.get(:mutelight_articles, Time.now + 60) do
        begin
          log :caching, key: :mutelight_articles
          BlackSwanClient.new.get_events("blog").map { |article|
            {
              published_at: Time.parse(article["occurred_at"]),
              slug:         article["slug"],
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

Dir[File.expand_path(File.dirname(__FILE__) + "/articles/*.rb")].map { |f| require(f) }
