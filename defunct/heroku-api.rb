module Org
  class Articles
    article "/heroku-api", {
      hook:         <<-eos,
The design and construction of the Heroku API.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-09-19T01:47:58Z"),
      signature:    true,
      title:        "Designing the Heroku API",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
