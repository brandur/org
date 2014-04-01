module Org
  class Articles
    article "/microservices", {
     hook:         <<-eos,
Useful distinction or new buzzword? Comments on 200-500 line services.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Tue Apr 01 05:37:17 PDT 2014"),
      signature:    true,
      title:        "Microservices",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
