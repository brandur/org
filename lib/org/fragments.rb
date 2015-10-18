require 'digest/md5'

module Org
  class Fragments < Sinatra::Base
    helpers Helpers::Common
    helpers Helpers::Markdown
    register Sinatra::Namespace

    before do
      log :access_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    configure do
      set :views, Config.root + "/views"
    end

    namespace "/fragments" do
      get do
        @title = "Fragments"
        @fragments = Fragments.fragments
        slim :"fragments/index", layout: !pjax?
      end

      get ".atom" do
        @fragments = Fragments.fragments
        builder :"fragments/index"
      end

      get "/:slug" do |slug|
        halt(404) unless @fragment = Fragments.fragments[slug]
        halt(404) unless @fragment[:published_at] <= Time.now.getutc
        if Config.production?
          last_modified(@fragment[:last_modified_at])
          etag(Digest::SHA1.hexdigest(@fragment[:content]))
        end
        @content = render_markdown(@fragment[:content])
        @title = @fragment[:title]
        slim :"fragments/show", layout: !pjax?
      end
    end

    private

    def self.build_fragments
      fragment_data = Dir[Config.root + "/fragments/**/*.md"].map { |f|
        contents = File.read(f)
        if contents =~ /\A(---\n.*?\n---)\n(.*)\Z/m
          meta = YAML.load($1)
          {
            content:          $2,
            image:            meta["image"],
            last_modified_at: Time.now,
            published_at:     meta["published_at"],
            slug:             File.basename(f).chomp(".md"),
            title:            meta["title"],
          }
        else
          raise "No YAML front matter for #{f}."
        end
      }.
        sort_by { |f| f[:published_at] }.
        select { |f| f[:published_at] <= Time.now.getutc }.
        reverse

      # take advantage of knowing about ordered hashes in Ruby to make sure
      # that these stay in the right order
      fragments = {}
      fragment_data.each do |fragment|
        fragments[fragment[:slug]] = fragment
      end
      fragments
    end

    def self.fragments
      if Config.production?
        # not threadsafe, but it doesn't matter
        @@fragments ||= build_fragments
      else
        build_fragments
      end
    end
  end
end
