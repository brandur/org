module Org::Helpers
  module Markdown
    include Common

    POST_RENDER_TRANSFORMS = [
      :transform_code_with_language_prefix,
      :transform_footnotes,
    ]

    PRE_RENDER_TRANSFORMS = [
      :transform_headers,
      :transform_figures,
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

    FIGURE = <<-eos.strip
<figure>
  <p><img src="%s"></p>
  <figcaption>%s</figcaption>
</figure>
    eos

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

    def render_kramdown(str)
      Kramdown::Document.new(str, input: 'GFM').to_html
    end

    def render_redcarpet(str)
      renderer = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new,
        Slim::Embedded.default_options[:markdown]
      )

      str = PRE_RENDER_TRANSFORMS.inject(str) { |str, m| method(m).call(str) }

      # Redcarpet now allows a new renderer to be defined. This would be better.
      html = renderer.render(str)

      html = POST_RENDER_TRANSFORMS.inject(html) { |html, m| method(m).call(html) }

      # replaces quotes with correct curly equivalents, etc.
      Redcarpet::Render::SmartyPants.render(html)
    end

    def transform_code_with_language_prefix(html)
      html.gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
    end

    # a super ghetto way of making figures a tad easier to write
    def transform_figures(str)
      rendered = str.dup

      str.scan(/(!fig src="(.*)" caption="(.*)")/) do |f, src, caption|
        rendered.gsub!(f, FIGURE % [src, caption])
      end

      rendered
    end

    # Note that this must be a post-transform filter. If it wasn't, our
    # Markdown renderer would not render the Markdown inside the footnotes
    # layer because it would already be wrapped in HTML.
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

          # find any references elsewhere in the document and turn them into
          # links
          main_content.gsub!(/\[#{number}\]/, FOOTNOTE_LINK % ([number] * 3))
        end

        # and wrap the whole section in a layer
        rendered = FOOTNOTE_WRAPPER % [rendered]

        html = main_content + rendered
      end
      html
    end

    # Transforms headers to HTML. We do this ourselves so that we can add
    # human-readable identifiers (naturally not supported by Markdown) and add
    # in links for them.
    def transform_headers(str)
      header_num = 0

      # Tracks previously assigned headers so that we can detect duplicates.
      headers = {}

      # matches one of the following:
      #   `# header`
      #   `# header (#header-id)`
      str.dup.scan(%r{^((#+)\s+([^(\n]*)(\s+\(#(.*)\))?)$}) do
        |header, level, title, _, id|
        h_num = level.length

        # give an unnamed header a `section-` prefix
        full_id = if !id
          "section-#{header_num}"
        # give a duplicate header a suffix like `-0`
        elsif num = headers[id]
          headers[id] += 1
          "#{id}-#{num}"
        # otherwise just use the given ID
        else
          headers[id] = 0
          id
        end

        str.gsub!(header, <<-eos.strip)
<h#{h_num} id="#{full_id}"><a href="##{full_id}">#{title}</a></h#{h_num}>
        eos
        header_num += 1
      end
      str
    end
  end
end
