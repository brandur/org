module Org
  class Articles
    article "/ed25519", {
      hook:         <<-eos,
Building internal authorization infrastructure based on the fast Ed25519 public key algorithm.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-08-12T16:46:42Z"),
      signature:    true,
      title:        "Distributed Authorization With Ed25519",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
