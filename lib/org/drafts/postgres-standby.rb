module Org
  class Articles
    article "/postgres-standby", {
      hook:         <<-eos,
How a Postgres standby server used only for analytical queries can produce feedback that can degrade a production system.
      eos
      location:     "Stockholm",
      published_at: Time.parse("2015-05-24T09:30:24Z"),
      signature:    true,
      title:        "Beware Your Postgres Standby"
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
