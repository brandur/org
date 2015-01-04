module Org
  class Articles
    article "/2015-running", {
=begin
      hook:         <<-eos,
An elegant weapon for a more civilized age. A list of tools for complete keyboard immersion.
      eos
=end
      location:     "Calgary",
      published_at: Time.parse("2015-01-04T05:42:54Z"),
      signature:    true,
      title:        "Setting a Running Goal for 2015. With Data. And Postgres.",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
