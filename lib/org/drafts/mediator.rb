module Org
  class Articles
    article "/mediator", {
      hook:         <<-eos,
Interactors by a different name.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Tue Mar 11 10:25:07 CDT 2014"),
      signature:    true,
      title:        "The Mediator Pattern",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
