module Org
  class Articles
    article "/keyboardist", {
      hook:         <<-eos,
An elegant weapon for a more civilized age. A list of tools for complete keyboard immersion.
      eos
      image:        "/assets/keyboardist/keyboardist.jpg",
      location:     "San Francisco",
      published_at: Time.parse("Tue Jul 24 07:54:44 PDT 2013"),
      signature:    true,
      title:        "The Keyboardist's Primer",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
