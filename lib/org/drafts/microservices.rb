module Org
  class Articles
    article "/microservices", {
     hook:         <<-eos,
Useful distinction over SOA, or new buzzword to sell more training courses?
      eos
      location:     "San Francisco",
      published_at: Time.parse("Mon Mar 17 09:01:10 PDT 2014"),
      signature:    true,
      title:        "Microservices",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
