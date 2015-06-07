module Org
  class Articles
    article "/mud", {
      hook:         <<-eos,
Microservice architecture is a broad field of study. Transitioning from the single orchestrator and over to log-based architecture.
      eos
      location:     "San Francisco",
      published_at: Time.parse("2015-05-16T21:11:49Z"),
      signature:    true,
      title:        "The Big Ball of Mud",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
