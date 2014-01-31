module Org
  class Articles
    article "/breaktime", {
    # hook:         <<-eos,
    # eos
      location:     "San Francisco",
      published_at: Time.parse("Thu Jan 30 22:15:17 PST 2014"),
      signature:    true,
      title:        "Give Me a Break",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
