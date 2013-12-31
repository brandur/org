module Org
  class Articles
    article "/death-of-the-page", {
      hook:         <<-eos,
How the page almost transitioned successfully to the digital world, but is in decline in the modern context of new media. The lessons that we can learn from this age-old design element.
      eos
      image:        "/assets/death-of-the-page/death-of-the-page.jpg",
      location:     "Calgary",
      published_at: Time.parse("Tue Dec 24 07:54:44 PDT 2013"),
      signature:    true,
      title:        "Lamenting the Death of the Page",
    } do
      render_article do
        slim :"articles/signature", layout: !pjax?
      end
    end
  end
end
