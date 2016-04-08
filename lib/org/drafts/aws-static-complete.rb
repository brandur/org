module Org
  class Articles
    article "/aws-static-complete", {
      hook:         <<-eos,
Building a static site on AWS with a global CDN, free HTTPS with automatic certificate renewal, and a deployment process based on GitHub pull requests.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-03-22T05:04:34Z"),
      signature:    true,
      title:        "The Complete AWS Static Site",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
