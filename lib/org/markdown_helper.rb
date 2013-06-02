module MarkdownHelper
  def self.render(str)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      fenced_code_blocks: true, hard_wrap: true)

    # Redcarpet now allows a new renderer to be defined. This would be better.
    renderer.render(str).
      gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
  end
end
