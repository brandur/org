module Org
  class Articles
    article "/order", {
      hook:         <<-eos,
On guaranteeing order with the bulk put API of an event stream.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-03-02T16:09:27Z"),
      signature:    true,
      title:        "Guaranteeing Order with Bulk Puts",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
