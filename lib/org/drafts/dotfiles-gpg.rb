module Org
  class Articles
    article "/dotfiles-gpg", {
      hook:         <<-eos,
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-11-10T17:25:22Z"),
      signature:    true,
      title:        "Dotfile Secrets and GPG",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
