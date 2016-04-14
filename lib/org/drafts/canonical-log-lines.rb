module Org
  class Articles
    article "/canonical-log-lines", {
      hook:         <<-eos,
Using canonical log lines for powerful, but succinct, introspection into a running system.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-04-14T17:03:10Z"),
      signature:    true,
      title:        "Canonical Log Lines",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
