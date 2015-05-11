module Org
  class Articles
    article "/postgres-queues", {
#      hook:         <<-eos,
#When building an app against an API, do you pull in their SDK or just make raw HTTP calls? Here are a few reasons that I don't want your SDK in production.
#      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-03T21:37:27Z"),
      signature:    true,
      title:        "Postgres-backed Job Queues & the MVCC Apocalypse",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
