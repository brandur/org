module Org
  class Articles
    article "/small-sharp-tools", {
      hook:         <<-eos,
A few words on the Unix philosophy of building small programs that do one thing well, and compose for more expansive functionality.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-09-28T01:41:11Z"),
      signature:    true,
      title:        "Small, Sharp Tools",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
