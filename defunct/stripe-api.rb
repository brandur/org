module Org
  class Articles
    article "/stripe-api", {
      hook:         <<-eos,
The design and major features of the Stripe API.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-10-18T22:05:04Z"),
      signature:    true,
      title:        "The Stripe API",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
