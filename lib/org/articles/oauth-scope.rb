module Org
  class Articles
    article "/oauth-scope", {
      hook: nil,
      location:     "San Francisco",
      published_at: Time.parse("Mon Jul 22 17:23:09 PDT 2013"),
      signature:    true,
      title:        "OAuth Scope",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
