module Org
  class Articles
    article "/beware-followers", {
      hook:         <<-eos,
How a follower used for analytical queries can produce feedback that can take down a production system.
      eos
      location:     "Stockholm",
      published_at: Time.parse("2015-05-19T01:24:34Z"),
      signature:    true,
      title:        "Beware Your (Postgres) Followers",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
