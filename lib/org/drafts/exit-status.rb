module Org
  class Articles
    article "/exit-status", {
      hook:         <<-eos,
An exercise of discovery around how to extend the shell's API.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-09-28T00:50:23Z"),
      signature:    true,
      title:        "Command Exit Status",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
