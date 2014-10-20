module Org
  class Articles
    article "/golang-packages", {
      hook:         <<-eos,
Understanding the benefits of Golang's restrictive (but simple) import and package management system.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-10-20T00:54:44Z"),
      signature:    true,
      title:        "Package Management in Go",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
