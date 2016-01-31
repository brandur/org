module Org
  class Articles
    article "/free-certificates", {
      hook:         <<-eos,
Getting a certificate that was signed by an authority used to be difficult and expensive, but not anymore! We've entered the golden age of web security. Read this for options for getting certificates issued for free.
      eos
      location:     "Vancouver",
      published_at: Time.parse("2016-01-31T17:48:53Z"),
      signature:    true,
      title:        "A Guide to Free CA-Signed Certificates",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
