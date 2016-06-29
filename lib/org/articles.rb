require 'digest/md5'

module Org
  class Articles < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Markdown
    helpers Helpers::TOC

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
      @articles = Articles.articles.values
      @articles.select! { |a| a[:published_at] <= Time.now.getutc }
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      slim :"articles/index", layout: !pjax?
    end

    get "/articles.atom" do
      @articles = Articles.articles.values
      @articles.select! { |a| a[:published_at] <= Time.now.getutc }
      @articles.sort_by! { |a| a[:published_at] }
      @articles.reverse!
      builder :"articles/index"
    end

    get "/:slug" do |slug|
      @article = Articles.articles[slug]
      if !@article || @article[:published_at] > Time.now.getutc
        pass
        return
      end
      @title = @article[:title]
      @content = render_markdown(@article[:content])
      @toc = build_toc(@content)
      if Config.production?
        last_modified(article[:last_modified_at])
        etag(Digest::SHA1.hexdigest(content))
      end
      slim :"articles/signature", layout: !pjax?
    end

    private

    def self.build_articles
      article_files = Dir[Config.root + "/articles/**/*.md"]

      unless Config.production?
        article_files += Dir[Config.root + "/drafts/**/*.md"]
      end

      article_data = article_files.map { |f|
        contents = File.read(f)
        if contents =~ /\A(---\n.*?\n---)\n(.*)\Z/m
          meta = YAML.load($1)
          {
            attributions:     meta["attributions"],
            content:          $2,
            hook:             meta["hook"],
            image:            meta["image"],
            last_modified_at: Time.now,
            location:         meta["location"],
            published_at:     meta["published_at"],
            slug:             File.basename(f).chomp(".md"),
            title:            meta["title"],
          }
        else
          raise "No YAML front matter for #{f}."
        end
      }.
        sort_by { |a| a[:published_at] }.
        select { |a| a[:published_at] <= Time.now.getutc }.
        reverse

      # take advantage of knowing about ordered hashes in Ruby to make sure
      # that these stay in the right order
      articles = {}
      article_data.each do |article|
        articles[article[:slug]] = article
      end
      articles
    end

    def render_content(article)
      path = "./articles2/" + article[:slug] + ".md"
      if !File.exists?(path) && !Org::Config.production?
        path = "./drafts2/" + article[:slug] + ".md"
      end
      render_markdown(File.read(path))
    end

    def self.articles
      if Config.production?
        # not threadsafe, but it doesn't matter
        @@articles ||= build_articles
      else
        build_articles
      end
    end
  end
end
