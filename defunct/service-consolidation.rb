module Org
  class Articles
    article "/service-consolidation", {
      hook:         <<-eos,
Steps for bringing distributed services back together in a safe way.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-12-18T17:57:33Z"),
      signature:    true,
      title:        "Service Consolidation",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
