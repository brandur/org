module Org
  class Articles
    article "/x100s-hack", {
      hook:         <<-eos,
If you find that the price tag for a Fuji-official adapter ring for the X100S is a little hard to swallow, this 5-minute hack will save you 90%.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Aug  3 09:50:19 PDT 2014"),
      signature:    true,
      title:        "A Cheap X100S Filter Ring Hack",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
