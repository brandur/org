module Org
  class Articles
    article "/self-serve", {
      hook:         <<-eos,
On building an internal culture of self-service APIs and tooling to prevent the proliferation of interrupt-driven development.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-02-16T22:09:57Z"),
      signature:    true,
      title:        "Self-serve",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
