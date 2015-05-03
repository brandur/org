module Org
  class Articles
    article "/kinesis-in-retrospect", {
      hook:         <<-eos,
A short write-up on findings, limitations, and opinion on Kinesis after a month in production.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-03T17:35:37Z"),
      signature:    true,
      title:        "Kinesis in Retrospect",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
