xml.instruct! :xml, :version => "1.0" 
xml.feed "xml:lang" => "en-US", :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "Fragments - brandur.org"
  xml.id "tag:brandur.org.org,2013:/fragments"
  xml.updated @fragments.values.first ? DateTime.parse(@fragments.values.first[:published_at].to_s).rfc3339 : nil
  xml.link rel: "alternate", type: "text/html", href: "https://brandur.org"
  xml.link rel: "self", type: "application/atom+xml", href: "https://brandur.org/fragments.atom"

  for _, fragment in @fragments
    xml.entry do
      xml.title fragment[:title]
      xml.content render_markdown(fragment[:content])
      xml.published DateTime.parse(fragment[:published_at].to_s).rfc3339
      xml.updated DateTime.parse(fragment[:published_at].to_s).rfc3339
      xml.link href: "https://brandur.org/fragments/#{fragment[:slug]}"
      xml.id "tag:brandur.org,#{fragment[:published_at].strftime('%F')}:fragments/#{fragment[:slug]}"
      xml.author do
        xml.name "Brandur Leach"
        xml.uri "https://brandur.org"
      end
    end
  end
end
