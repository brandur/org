module Org
  class Articles
    article "/stripe-running", {
      hook:         <<-eos,
Crunching running data with prepared statements in Postgres.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-10-24T20:55:32Z"),
      signature:    true,
      title:        "Running at Stripe",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
