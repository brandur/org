module Org
  class Articles
    article "/logfmt", {
      hook:         <<-eos,
A logging format used inside companies such as Heroku and Stripe which is optimal for easy development, consistency, and good legibility for humans and computers.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Mon Oct 28 09:28:04 PDT 2013"),
      signature:    true,
      title:        "logfmt",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
