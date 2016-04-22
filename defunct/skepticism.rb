module Org
  class Articles
    article "/skepticism", {
      hook:         <<-eos,
Applying responsible skepticism to lauded technical architectures.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-02-25T16:56:06Z"),
      signature:    true,
      title:        "Skepticism",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
