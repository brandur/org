module Org
  class Articles
    article "/kinesis-consumers", {
      hook:         <<-eos,
Designing an algorithm for Kinesis consumers that guarantees record ordering even across shard splits and merges.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-03-19T07:38:08Z"),
      signature:    true,
      title:        "A Generalized Kinesis Consumer Algorithm",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
