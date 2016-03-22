module Org
  class Articles
    article "/aws-static-complete", {
      hook:         <<-eos,
A complete static website on AWS.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-03-22T05:04:34Z"),
      signature:    true,
      title:        "The Complete AWS Static Site",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
