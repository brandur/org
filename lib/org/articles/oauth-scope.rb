module Org
  class Articles
    article "/oauth-scope", {
      hook:         <<-eos,
Designing scope for Heroku OAuth, and a brief tour of other implementations on the web.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Tue Jul 23 07:54:44 PDT 2013"),
      signature:    true,
      title:        "Scoping and OAuth 2",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
