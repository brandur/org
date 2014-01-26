module Org
  class Articles
    article "/page", {
      hook:         <<-eos,
How the page almost transitioned successfully to the digital world, but is in decline in the modern context of new media. The lessons that we can learn from this age-old design element, and why we should hope for its re-emergence.
      eos
      image:        "/assets/page/page.jpg",
      location:     "San Francisco",
      published_at: Time.parse("Sun Jan 26 10:56:46 PST 2014"),
      signature:    true,
      title:        "Lamenting the Death of the Page",
      attributions: <<-eos
Header image by <strong><a href="https://www.flickr.com/photos/67499195@N00/717747166">Andreas Levers</a></strong>. Licensed under Creative Commons BY-NC 2.0.
      eos
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
