module Org
  class Articles
    article "/go", {
      hook:         <<-eos,
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-03-10T05:32:08Z"),
      signature:    true,
      title:        "Notes on Go",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
