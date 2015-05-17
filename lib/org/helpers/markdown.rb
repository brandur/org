module Org::Helpers
  module Markdown
    include Common

    POST_RENDER_TRANSFORMS = [
      :transform_code_with_language_prefix,
      :transform_footnotes,
    ]

    def render_markdown(str)
      log :render_markdown do
        if RUBY_PLATFORM == 'java'
          render_kramdown(str)
        else
          render_redcarpet(str)
        end
      end
    end

    private

    def render_kramdown(str)
      Kramdown::Document.new(str, input: 'GFM').to_html
    end

    def render_redcarpet(str)
      renderer = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new({
          with_toc_data: true
        }),
        Slim::Embedded.default_options[:markdown]
      )

      # Redcarpet now allows a new renderer to be defined. This would be better.
      html = renderer.render(str)

      html = POST_RENDER_TRANSFORMS.inject(html) { |html, m| method(m).call(html) }

      # replaces quotes with correct curly equivalents, etc.
      Redcarpet::Render::SmartyPants.render(html)
    end

    def transform_code_with_language_prefix(html)
      html.gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
    end

    FOOTNOTE_ANCHOR = <<-eos.gsub(/\n/, '').gsub(/>\s+</, '><').strip
      <sup id="footnote-%s">
        <a href="#footnote-%s-source">%s</a>
      </sup>
    eos

    FOOTNOTE_LINK = <<-eos.gsub(/\n/, '').gsub(/>\s+</, '><').strip
      <sup id="footnote-%s-source">
        <a href="#footnote-%s">%s</a>
      </sup>
    eos

    FOOTNOTE_WRAPPER = <<-eos.strip
      <div id="footnotes">
        %s
      </div>
    eos

    def transform_footnotes(html)
      # look for the section the section at the bottom of the page that looks
      # like <p>[1] (the paragraph tag is there because Markdown will have
      # already wrapped it by this point)
      if html =~ /^(<p>\[\d+\].*)/m
        footnotes = $1
        rendered = footnotes.dup
        main_content = html.sub(footnotes, '')

        footnotes.scan(/(\[(\d+)\]\s+.*)/) do |_, number|
          # render the footnote itself
          rendered.gsub!("[#{number}]", FOOTNOTE_ANCHOR % ([number] * 3))

          # find any referenfes elsewhere in the document and turn them into
          # links
          main_content.gsub!(/\[#{number}\]/, FOOTNOTE_LINK % ([number] * 3))
        end

        # and wrap the whole section in a layer
        rendered = FOOTNOTE_WRAPPER % [rendered]

        html = main_content + rendered
      end
      html
    end
  end
end
