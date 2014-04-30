module Org
  class Articles
    article "/schema-stubs", {
      hook: <<-eos,
Stubbing distributed services with Sinatra-based services stubs and enabling stronger constraints with JSON Schema.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Wed Apr 30 09:23:22 PDT 2014"),
      signature:    true,
      title:        "Testing Distributed Services with JSON Schema",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
