module Org
  class Articles
    article "/kinesis-by-example", {
      hook:         <<-eos,
A quick demonstration of shards in a Kinesis stream being split and merged.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-03-19T06:37:17Z"),
      signature:    true,
      title:        "Kinesis Shard Splitting & Merging by Example",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
