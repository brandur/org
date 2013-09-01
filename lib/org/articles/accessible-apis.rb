module Org
  class Articles
    article "/accessible-apis", {
      hook: <<-eos,
A set of patterns to make APIs more accessible to developers; lowering the barrier of entry for new users, and easing the maintenance of consuming applications.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Sep  1 08:59:44 PDT 2013"),
      signature:    true,
      title:        "Developer Accessible APIs",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
