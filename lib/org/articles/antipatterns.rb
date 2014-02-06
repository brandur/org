module Org
  class Articles
    article "/antipatterns", {
      hook: <<-eos,
When the use an anti-pattern is considered beneficial.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Thu Feb  6 07:31:37 PST 2014"),
      signature:    true,
      title:        "Healthy Anti-patterns",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
