require "time"
require "yaml"

AllArticles = {}

module Org
  class Articles
    def self.article(route, metadata={}, &block)
      slug = route.gsub(/^\/*/, "")
      metadata.merge!({
      })
      AllArticles[route] = metadata
    end
  end
end

def retrofit(dir)
  Dir[File.expand_path(File.dirname(__FILE__) + "/../lib/org/#{dir}/*.rb")].map { |f| require(f) }

  Dir[File.expand_path(File.dirname(__FILE__) + "/../#{dir}/*.md")].map { |f|
    slug = File.basename(f, ".md")
    meta = AllArticles["/" + slug]
    if !meta
      abort("No meta-information found for: #{f}")
    end

    meta[:attributions] = meta[:attributions].strip if meta[:attributions]
    meta[:hook] = meta[:hook].strip
    meta[:published_at] = meta[:published_at].getutc

    meta.delete(:signature)

    new_meta = meta.dup
    meta.each do |k, v|
      new_meta[k.to_s] = v
      new_meta.delete(k)
    end
    meta = new_meta

    contents = File.read(f)

    File.open(File.dirname(__FILE__) + "/../#{dir}2/#{slug}.md", 'w') do |f|
      f.write(YAML.dump(meta))
      f.write("---")
      f.write("\n")
      f.write("\n")
      f.write(contents)
    end
  }
end

retrofit("articles")
retrofit("drafts")

