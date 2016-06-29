module Org
  class Articles
    article "/qe", {
      hook:         <<-eos,
Quantitative easing explained in a pragmatic way (and with an example).
      eos
      image:        "/assets/qe/qe2.jpg",
      location:     "San Francisco",
      published_at: Time.parse("Thu Jan 30 22:15:17 PST 2014"),
      signature:    true,
      title:        "Quantitative Easing for Hackers",
      attributions: <<-eos
Header image by <strong><a href="http://www.flickr.com/photos/gammaman/6242455757/">Eli Christman</a></strong>. Licensed under Creative Commons BY 2.0.
      eos
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
