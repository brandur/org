module Org
  class Articles
    article "/postgres-queues", {
      hook:         <<-eos,
How Postgres' concurrency model coupled with long-lived transactions can degrade the performance of indexes on hot tables in your database.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-18T23:13:23Z"),
      signature:    true,
      title:        "Postgres Job Queues & Failure By MVCC",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
