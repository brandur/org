module Org
  class Articles
    article "/go", {
      hook:         <<-eos,
Notes on the language after spending a few weeks building a large project in it.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-03-31T20:37:11Z"),
      signature:    true,
      title:        "Notes on Go",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
