module Org
  class Articles
    article "/breaktime", {
      hook:         <<-eos,
In search for (and the discovery of) an alternative to BreakTime.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Feb  2 10:15:28 PST 2014"),
      signature:    true,
      title:        "BreakTime Classic",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
