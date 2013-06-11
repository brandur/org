module Org
  class Articles
    article "/service-stubs", {
      hook: <<-eos,
How we build minimal, platform deployable, Rack service stubs to take the pain out of developing applications that depend on an extensive service-oriented architecture.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Jun  3 10:22:11 PDT 2013"),
      signature:    true,
      title:        "SOA and Service Stubs",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
