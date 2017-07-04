xml.instruct!
xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do

  xml.channel do
    xml.title 'Dukop.dk'
    xml.description 'Blah blah'
    xml.link root_url
    xml.language 'en'

    for event in @events
      xml.item do
        xml.title event.title
        xml.link event_url(event)
        xml.pubDate(event.created_at.rfc2822)
        xml.id event.id
        xml.description(h(event.long_description))
      end
    end

  end

end
