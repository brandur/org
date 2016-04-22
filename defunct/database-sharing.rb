module Org
  class Articles
    article "/database-sharing", {
      hook:         <<-eos,
Sharing a database across services is an incredibly tempting pattern, but may be the worst bad habit of distributed systems. Lets examine why.
      eos
      location:     "Budapest (finished in San Francisco)",
      published_at: Time.parse("2016-01-24T23:46:12Z"),
      signature:    true,
      title:        "Don't Share Your Database",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
