xml.instruct! :xml, :version => "1.0" 
xml.feed "xml:lang" => "en-US", :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "brandur.org"
  xml.id "tag:brandur.org.org,2013:/articles"
  xml.updated @articles.first ? DateTime.parse(@articles.first[:published_at].to_s).rfc3339 : nil
  xml.link rel: "alternate", type: "text/html", href: "https://brandur.org"
  xml.link rel: "self", type: "application/atom+xml", href: "https://brandur.org/articles.atom"

  for article in @articles
    xml.entry do
      xml.title article[:title]
      #xml.content Tilt.new("./articles/" + article[:slug] + ".md", Slim::Embedded.default_options[:markdown]).render, type: "html"
      xml.content render_content(article)
      xml.published DateTime.parse(article[:published_at].to_s).rfc3339
      xml.updated DateTime.parse(article[:published_at].to_s).rfc3339
      xml.link href: "https://brandur.org/#{article[:slug]}"
      xml.id "tag:brandur.org,#{article[:published_at].strftime('%F')}:#{article[:slug]}"
      xml.author do
        xml.name "Brandur Leach"
        xml.uri "http://brandur.org"
      end
    end
  end
end
