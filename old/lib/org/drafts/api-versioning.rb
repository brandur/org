module Org
  class Articles
    article "/api-versioning", {
      hook:         "",
      published_at: Time.parse("Sun Sep  1 08:59:44 PDT 2013"),
      signature:    true,
      title:        "API Versioning",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
