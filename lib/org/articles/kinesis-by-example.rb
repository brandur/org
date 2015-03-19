module Org
  class Articles
    article "/kinesis-by-example", {
      hook:         <<-eos,
Splitting and merging in action.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-03-19T07:27:45Z"),
      signature:    true,
      title:        "Kinesis Shard Splitting & Merging by Example",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
