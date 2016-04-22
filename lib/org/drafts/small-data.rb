module Org
  class Articles
    article "/small-data", {
      hook:         <<-eos,
Everyone thinks that they're Google.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-04-22T21:41:42Z"),
      signature:    true,
      title:        "In Defense of Small Data",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
