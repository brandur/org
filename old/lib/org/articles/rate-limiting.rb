module Org
  class Articles
    article "/rate-limiting", {
      hook:         <<-eos,
Implementing rate limiting using Generic Cell Rate Algorithm (GCRA), a sliding window algorithm without a drip process.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-09-18T16:42:18Z"),
      signature:    true,
      title:        "Rate Limiting, Cells, and GCRA",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
