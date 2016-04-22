module Org
  class Articles
    article "/hypermedia", {
#      hook:         <<-eos,
#When building an app against an API, do you pull in their SDK or just make raw HTTP calls? Here are a few reasons that I don't want your SDK in production.
#      eos
      location:     "San Francisco",
      published_at: Time.parse("Mon Jan 27 11:36:46 PST 2014"),
      signature:    true,
      title:        "Your API Doesn't Need Hypermedia; it Needs a Conservative Change Policy",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
