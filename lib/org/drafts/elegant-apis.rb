module Org
  class Articles
    article "/elegant-apis", {
      hook:         <<-eos,
A quick tour through some of the fundamentals of JSON Schema and Hyper-schema, and how they can be applied to building APIs.
      eos
      location:     "Berlin",
      published_at: Time.parse("Mon May 26 09:26:59 CEST 2014"),
      signature:    true,
      title:        "Elegant APIs with JSON Schema",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
