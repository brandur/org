module Org
  class Articles
    article "/rate-limiting", {
      hook:         <<-eos,
Implementing rate limiting using Genetic Cell Rate Algorithm (GCRA), a sliding window algorithm without a drip process.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-08-30T16:40:36Z"),
      signature:    true,
      title:        "Rate Limiting and GCRA",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
