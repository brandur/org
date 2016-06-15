module Org
  class Articles
    article "/aws-islands", {
      hook:         <<-eos,
The case for a concerted effort to build a powerful, but streamlined, platform
on AWS.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2016-06-15T15:24:53Z"),
      signature:    true,
      title:        "AWS Islands",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
