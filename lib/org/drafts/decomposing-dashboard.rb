module Org
  class Articles
    article "/decomposing-dashboard", {
      hook:         <<-eos,
A logging format used inside Heroku optimal for easy development, as well as good legibility for humans and computers.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Thu Oct 22 15:32:45 PDT 2013"),
      signature:    true,
      title:        "Decomposing Dashboard",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
