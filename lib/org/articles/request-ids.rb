module Org
  class Articles
    article "/request-ids", {
      hook: <<-eos,
A simple pattern for tracing requests across a service-oriented architecture by injecting a UUID into the events that they produce.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Jun  2 10:21:43 PDT 2013"),
      title:        "Tracing Request IDs",
    } do
      render_article do
        slim :"articles/generic", layout: !pjax?
      end
    end
  end
end
