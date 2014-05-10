require 'digest/md5'

module Org
  class Fragments < Sinatra::Base
    helpers Helpers::Common
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

      get "/modern" do
        slim :"fragments/show", layout: !pjax?
      end
    end

    private

    def self.fragments
      # not threadsafe, but it doesn't matter
      @@fragments ||= begin
        fragment_data = Dir[Config.root + "/fragments/**/*.md"].map { |f|
          contents = File.read(f)
          if contents =~ /\A(---\n.*?\n---)\n(.*)\Z/m
            meta = YAML.load($1)
            {
              content:      $2,
              published_at: meta["published_at"],
              slug:         File.basename(f).chomp(".md"),
              title:        meta["title"],
            }
          else
            raise "No YAML front matter for #{f}."
          end
        }.sort_by { |f| f[:published_at] }.reverse

        # take advantage of knowing about ordered hashes in Ruby to make sure
        # that these stay in the right order
        fragments = {}
        fragment_data.each do |fragment|
          fragments[fragment[:slug]] = fragment
        end
        fragments
      end
    end
  end
end
