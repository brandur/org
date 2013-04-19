require 'digest/md5'

module BrandurOrg
  class Articles < Sinatra::Base
    # hashes are sorted in 1.9+ (and this one is reverse published order)
    ARTICLES = Hash[Dir["#{Config.root}/articles/**/*.rb"].map { |article|
      slug    = File.basename(article, ".rb")
      attrs   = Kernel.eval(File.read(article))
      content = File.read("#{Config.root}/articles/#{slug}.md")
      [slug, attrs.merge({
        content:          MarkdownHelper.render(content),
        digest:           Digest::MD5.hexdigest(content),
        last_modified_at: File.new(article).mtime.utc,
        slug:             slug,
      })]
    }.sort_by { |_, article| article[:published_at] }.reverse]

    configure do
      set :views, Config.root + "/views"
    end

    get "/the-old-man" do
      slim :"articles/the-old-man"
    end

    ARTICLES.each do |slug, _|
      get "/#{slug}" do
        @article = ARTICLES[slug]
        if Config.production?
          last_modified(@article[:last_modified_at])
          etag(@article[:digest])
        end
        slim :article
      end
    end
  end
end
