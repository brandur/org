module Org
  class Articles
    article "/breaktime", {
      hook:         <<-eos,
In search for (and the discovery of) an alternative to BreakTime.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Thu Jan 30 22:15:17 PST 2014"),
      signature:    true,
      title:        "BreakTime Classic",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
