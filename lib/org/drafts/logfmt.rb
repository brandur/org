module Org
  class Articles
    article "/logfmt", {
      hook:         <<-eos,
A logging format used inside Heroku optimal for easy development, consistency, and good legibility for humans and computers.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Thu Oct 17 15:32:45 PDT 2013"),
      signature:    true,
      title:        "logfmt",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
