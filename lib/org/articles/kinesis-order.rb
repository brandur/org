module Org
  class Articles
    article "/kinesis-order", {
      hook:         <<-eos,
On guaranteeing order with the bulk put API of an event stream.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-03-05T01:13:46Z"),
      signature:    true,
      title:        "Guaranteeing Order with Kinesis Bulk Puts",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
