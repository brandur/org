module Org
  class Articles
    article "/accessible-apis", {
      hook: <<-eos,
A simple book of patterns on how to make APIs more accessible.
      eos
      location:     "Calgary",
      published_at: Time.parse("Tue Aug 20 12:16:40 PDT 2013"),
      signature:    true,
      title:        "Developer Accessible APIs",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
