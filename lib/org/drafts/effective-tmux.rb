module Org
  class Articles
    article "/effective-tmux", {
      hook:         <<-eos,
Now that you have your basic Tmux setup running, it's time to dive in and make it your fully integrated development environment.
      eos
      location:     "San Francisco",
      published_at: Time.parse("Sun Aug  3 10:43:39 PDT 2014"),
      signature:    true,
      title:        "Effective Tmux",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
