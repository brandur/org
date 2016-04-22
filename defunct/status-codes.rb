module Org
  class Articles
    article "/status-codes", {
=begin
      hook:         <<-eos,
An elegant weapon for a more civilized age. A list of tools for complete keyboard immersion.
      eos
=end
      location:     "San Francisco",
      published_at: Time.parse("Sun Sep 29 11:39:45 PDT 2013"),
      signature:    true,
      title:        "Signals in Status Codes",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
