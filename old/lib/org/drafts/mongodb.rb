module Org
  class Articles
    article "/mongodb", {
      hook:         <<-eos,
Why MongoDB is never the right choice.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-06-08T03:57:09Z"),
      signature:    true,
      title:        "MongoDB",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
