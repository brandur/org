module Org
  class Articles
    article "/database-sharing", {
      hook:         <<-eos,
Sharing a database across services is an incredibly tempting pattern, but may be the worst bad habit of distributed systems. Lets examine why.
      eos
      location:     "Budapest",
      published_at: Time.parse("2015-05-30T17:35:55Z"),
      signature:    true,
      title:        "Don't Share Your Database",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
