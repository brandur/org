module Org
  class Articles
    article "/heroku-values", {
      hook:         <<-eos,
Some of the things that I came to appreciate while working at Heroku.
      eos
      image:        "/assets/heroku-values/heroku-values.jpg",
      location:     "San Francisco",
      published_at: Time.parse("2015-09-14T22:18:58Z"),
      signature:    true,
      title:        "My Heroku Values",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
