module Org
  class Articles
    article "/warehouse", {
      hook:         <<-eos,
Data warehouses aren't just for the enterprise! Let's examine a few of their basic characteristics, and build some examples with Go/Ruby and Postgres.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2014-09-05T16:25:04Z"),
      signature:    true,
      title:        "The Humble Data Warehouse",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
