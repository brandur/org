module Org
  class Articles
    article "/version-variants", {
      hook:         <<-eos,
A simple mechanism for managing changes to a web API and to help cheapen the disposal of prototypes.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-02-16T20:24:43Z"),
      signature:    true,
      title:        "Version Variants",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
