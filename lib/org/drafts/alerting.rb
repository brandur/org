module Org
  class Articles
    article "/alerting", {
      hook:         <<-eos,
Ten general pieces of advice to consider when designing a set of alerts for a production system.
      eos
      location:     "Leipzig",
      published_at: Time.parse("2015-05-24T09:32:24Z"),
      signature:    true,
      title:        "Ten Tips for Designing Alerts"
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
