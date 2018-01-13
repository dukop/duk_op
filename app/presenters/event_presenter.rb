class EventPresenter

  attr_reader :object

  def initialize(object, view_context)
    @object = object
    @view_context = view_context
  end

  def description
    @object.short_description
  end

  def card_view
    render partial: '/events/card.html.erb', locals: { presenter: self }
  end

  def location
    link_to(@object.location.display_name, @object.location)
  end

  def time
    @object.start_time.strftime('%H:%M')
  end

  def date
    I18n.localize(@object.start_time, format: :header)
  end

  def title
    if @object.cancelled?
      "<s>#{@object.title}</s> - <span class='text-danger'>#{I18n.t('events.event.cancelled')}</span>".html_safe
    else
      @object.title
    end
  end

  def teaser
    truncate(@object.short_description, length: 450, separator: ' ')
  end

  def more_description
    auto_link(simple_format(@object.short_description))
  end

  def fb_tags
    tags = []
    tags << fb_url
    tags << fb_type
    tags << fb_title
    tags << fb_description
    tags << fb_image
    tags << fb_site_name
    tags << fb_locale
    tags.join("\n").html_safe
  end

  def fb_url
    fb_tag('url', event_url(@object))
  end

  # There doesn't seem to be a better Open Graph type for events
  # See https://developers.facebook.com/docs/reference/opengraph#object-type
  def fb_type
    fb_tag('type', 'article')
  end

  def fb_title
    extended_title = "#{@object.title}, #{date_short}, #{@object.location.display_name}"
    fb_tag('title', extended_title)
  end

  def fb_description
    shortened_description = description.split('. ').take(4).join('. ')
    fb_tag('description', shortened_description)
  end

  def fb_site_name
    fb_tag('site_name', I18n.t(:app_name))
  end

  # We're hardcoding to a Danish locale here because most of the content
  # is in Danish even if the interface is in English
  def fb_locale
    fb_tag('locale', 'da_DK')
  end

  def fb_image
    if @object.best_picture.present?
      fb_tag('image', asset_url(@object.best_picture.url(:original)))
    else
      ''
    end
  end

  def picture_tag
    image_tag(@object.best_picture, alt: '') if @object.best_picture.present?
  end

  def date_short
    I18n.localize(@object.start_time.to_date, format: :brief)
  end

  def fb_tag(type, content)
    tag 'meta', { property: "og:#{type}", content: content }, true
  end

  def ics_link
    link_to(t('events.event.download_ics'), event_path(@object, format=:ics))
  end

  private

  # This forwards undefined methods to
  # the view context, e.g. link_to etc
  def method_missing(*args, &block)
    @view_context.send(*args, &block)
  end
end
