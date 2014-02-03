module Org
  class Articles
    article "/sdk", {
      hook:         <<-eos,
When building an app against a web API, do you pull in their SDK or just make raw HTTP calls? Here are a few reasons that I avoid SDKs when I can.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Mon Feb  3 06:46:52 PST 2014"),
      signature:    true,
      title:        "Why I Don't Want Your SDK in Production",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
