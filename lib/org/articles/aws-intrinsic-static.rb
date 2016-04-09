module Org
  class Articles
    article "/aws-intrinsic-static", {
      hook:         <<-eos,
Building a static site on AWS with a global CDN, free HTTPS with automatic certificate renewal, and a CI-based deployment process powered by GitHub pull requests.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-04-09T02:11:19Z"),
      signature:    true,
      title:        "The Intrinsic Static Site",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
