module Org
  class Articles
    article "/page", {
      hook:         <<-eos,
How the page almost transitioned successfully to the digital world, but is in decline in the modern context of new media. The lessons that we can learn from this age-old design element.
      eos
      image:        "/assets/page/page.jpg",
      location:     "Calgary",
      published_at: Time.parse("Tue Dec 24 07:54:44 PDT 2013"),
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
