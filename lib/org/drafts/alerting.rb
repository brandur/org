module Org
  class Articles
    article "/alerting", {
      hook:         <<-eos,
A set of general guidelines to consider when designing a alerts for a production system.
      eos
      location:     "Leipzig (finished in San Francisco)",
      published_at: Time.parse("2015-05-24T09:32:24Z"),
      signature:    true,
      title:        "Designing Alerts"
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
