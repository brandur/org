module Org
  class Articles
    article "/postgres-queues", {
      hook:         <<-eos,
How long-lived transactions can cause serious trouble for hot tables due to the way that Postgres' concurrency model is implemented.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-14T15:37:27Z"),
      signature:    true,
      title:        "Postgres Job Queues & Failure By MVCC",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
