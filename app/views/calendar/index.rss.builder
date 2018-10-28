xml.instruct!
xml.rss version: '2.0' do
  xml.channel do
    xml.title t('app_name')
    xml.link root_url
    xml.docs 'http://cyber.law.harvard.edu/rss/rss.html'
    xml.ttl '30'

    @calendar.events.each do |event|
      xml.item do
        xml.title title_display(event)
        xml.link event_url(event)
        xml.guid event_url(event)
        xml.description rss_description(event)
        xml.pubDate rss_pub_date(event)
        xml.enclosure(rss_image_attrs(event)) if event.has_picture?
        event.categories.each do |category|
          xml.category transl_cat(category)
        end
      end
    end
  end
end
