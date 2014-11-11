module Org
  class Articles
    article "/dotfile-gpg", {
      hook:         <<-eos,
Learn how to start encrypting dotfile secrets with GPG, and some techniques for getting those encrypted files integrated with your toolchain.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-11-10T23:46:34Z"),
      signature:    true,
      title:        "Dotfile Secrets and GPG",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
