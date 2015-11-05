module Org
  class Articles
    article "/heroku-values", {
      hook:         <<-eos,
In retrospect, some of my favorite practices and ideas from almost four years at Heroku.
      eos
      image:        "/assets/heroku-values/heroku-values.jpg",
      location:     "San Francisco",
      published_at: Time.parse("2015-11-05T06:20:16Z"),
      signature:    true,
      title:        "My Heroku Values",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
