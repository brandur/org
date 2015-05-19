module Org
  class Articles
    article "/beware-standby-servers", {
      hook:         <<-eos,
How a standby used for analytical queries can produce feedback that can degrade a production system.
      eos
      location:     "Stockholm",
      published_at: Time.parse("2015-05-19T01:24:34Z"),
      signature:    true,
      title:        "Beware Your (Postgres) Standby Servers",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
