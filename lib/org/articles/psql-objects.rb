module Org
  class Articles
    article "/psql-objects", {
      hook:         <<-eos,
Using backslash commands in psql to navigate and describe object hierarchy in Postgres and Redshift.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-10-26T16:08:30Z"),
      signature:    true,
      title:        "Exploring Object Hierarchies in Psql",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
