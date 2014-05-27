require 'digest/md5'

module Org
  class Articles < Sinatra::Base
    @@articles = {}

    helpers Helpers::Common
    helpers Helpers::Markdown

    def self.article(route, metadata={}, &block)
      slug = route.gsub(/^\/*/, "")
      metadata.merge!({
        last_modified_at: Time.now.getutc,
        slug: slug,
      })
      @@articles[route] = metadata
      get(route, &block)
    end

    def self.articles
      articles = @@articles.values
      articles.select! { |a| a[:published_at] <= Time.now.getutc }
      articles.sort_by! { |a| a[:published_at] }
      articles.reverse!
      articles
    end

    configure do
      set :views, Config.root + "/views"
    end

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    get "/articles" do
      @title = "Articles"
      @viewport_width = "600"
      @articles = @@articles.values
      @articles.select! { |a| a[:published_at] <= Time.now.getutc }
      #@articles += mutelight_articles
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      slim :"articles/index", layout: !pjax?
    end

    get "/articles.atom" do
      @articles = @@articles.values
      @articles.select! { |a| a[:published_at] <= Time.now.getutc }
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      builder :"articles/index"
    end

    private

    def mutelight_articles
      DB[:events].reverse_order(:occurred_at).filter(type: "blog").limit(10).
        map { |article|
          {
            published_at: article[:occurred_at],
            slug:         article[:slug],
            title:        article[:content],
          }
        }
    end

    def render_article
      @article = @@articles[request.path_info]
      halt(404) unless @article[:published_at] <= Time.now.getutc
      last_modified(@article[:last_modified_at]) if Config.production?
      @title = @article[:title]
      @content = render_content(@article)
      data = yield
      etag(Digest::SHA1.hexdigest(data)) if Config.production?
      data
    end

    def render_content(article)
      path = "./articles/" + article[:slug] + ".md"
      if !File.exists?(path) && !Org::Config.production?
        path = "./drafts/" + article[:slug] + ".md"
      end
      render_markdown(File.read(path))
    end
  end
end

Dir[File.expand_path(File.dirname(__FILE__) + "/articles/*.rb")].map { |f| require(f) }

unless Org::Config.production?
  Dir[File.expand_path(File.dirname(__FILE__) + "/drafts/*.rb")].map { |f| require(f) }
end
