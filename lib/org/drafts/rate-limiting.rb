module Org
  class Articles
    article "/rate-limiting", {
      hook:         <<-eos,
Implementing rate limiting using Generic Cell Rate Algorithm (GCRA), a sliding window algorithm without a drip process.
      eos
#      image:        "/assets/rate-limiting/rate-limiting-blt.jpg",
      location:     "San Francisco",
      published_at: Time.parse("2015-08-30T16:40:36Z"),
      signature:    true,
      title:        "Rate Limiting and GCRA",
#      attributions: <<-eos
#Header image by <strong><a href="https://www.flickr.com/photos/javmorcas/6326542870/">Javier Morales</a></strong>. Licensed under Creative Commons BY-NC-ND 2.0.
#      eos
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
