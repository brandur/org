module Org
  class Articles
    article "/real-time-apis", {
      hook:         <<-eos,
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Oct 27 13:54:32 PDT 2013"),
      signature:    true,
      title:        "Real Time APIs",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
