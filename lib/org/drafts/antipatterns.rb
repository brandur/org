module Org
  class Articles
    article "/antipatterns", {
      hook: <<-eos,
When an anti-pattern is okay.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Feb  2 09:47:12 PST 2014"),
      signature:    true,
      title:        "Healthy Anti-patterns",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
