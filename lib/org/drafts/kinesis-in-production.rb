module Org
  class Articles
    article "/kinesis-in-production", {
      hook:         <<-eos,
A short write-up on findings, limitations, and opinion on Kinesis after a month in production.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-03T17:35:37Z"),
      signature:    true,
      title:        "A Month of Kinesis in Production",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
