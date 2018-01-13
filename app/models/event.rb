class Event < ActiveRecord::Base
  validates :title, :short_description, :start_time, :end_time, :location_id, :user_id, :categories, presence: true
  validate :must_be_future_event
  validate :must_be_valid_duration

  belongs_to :user
  belongs_to :location
  belongs_to :event_series
  has_and_belongs_to_many :categories
  has_many :comments
  has_attached_file :picture, styles: { original: '500x500>', thumb: '100x100>'}, default_url: 'images/:st'

  validates_attachment_content_type :picture, :content_type => /\Aimage/
  validates_attachment_file_name :picture, matches: [/png\Z/i, /jpe?g\Z/i]
  validates_with AttachmentSizeValidator, attributes: :picture, less_than:  3.megabytes

  scope :published, -> { where(published: true) }
  scope :future, -> { where('events.end_time > ?', DateTime.now) }
  scope :ordered, -> { order('events.start_time') }
  scope :in_series, -> { where('event_series_id > 0') }
  scope :not_started, -> { where('start_time >= ?', DateTime.now) }
  scope :this_week, -> { where('start_time <= ?', DateTime.now + 6.days) }
  scope :unpublished, -> { future.where(published: false).ordered }
  scope :coming, -> { future.published.ordered }

  before_validation :fix_link

  def fix_link
    if self.link?
      unless self.link[/^https?:\/\//]
        self.link = "http://" + self.link
      end
    end
  end
  
  def must_be_valid_duration
    return unless end_time.present? && start_time.present?
    unless end_time > start_time
      errors.add(:end_time, I18n.t('events.form.invalid_duration'))
    end
  end

  def must_be_future_event
    return if persisted?
    return unless end_time.present? && start_time.present?
    if start_time < DateTime.now
      errors.add(:start_time, I18n.t('events.form.past_event'))
    elsif end_time < DateTime.now
      errors.add(:end_time, I18n.t('events.form.past_event'))
    end
  end

  def in_progress?
    start_time < DateTime.now && end_time > DateTime.now
  end

  def <=>(other)
    start_time <=> other.start_time
  end

  def description=(val)
    self.short_description = val
  end

  # the name method is an alias used
  # by the page title helper
  def name
    title
  end

  def best_picture
    if picture.present?
      picture
    elsif event_series.present? && event_series.picture.present?
      event_series.picture
    else
      nil
    end
  end

  def has_picture?
    best_picture.present?
  end

  def picture_url
    best_picture.url(:original)
  end

  def weekly?
    event_series.present? && event_series.rule == 'weekly'
  end

  def unpublished?
    !published?
  end

  def self.current_events
    self.includes(:user, :location, :event_series).coming
  end

  def self.main_calendar
    Event.current_non_repeating + Event.current_non_weekly
  end

  def self.current_non_weekly
    self.includes(:user, :location)
      .joins(:event_series)
      .where.not('event_series.rule': 'weekly')
      .coming
  end

  def self.current_non_repeating
    self.includes(:user, :location)
      .coming
      .where(event_series_id: nil)
  end

  def self.featured_events
    self.current_events.where(featured: true).limit(3)
  end

  def self.non_featured_events
    self.current_events
        .where.not(featured: true)
        .where('event_series_id IS NULL')
  end

  # Highlights is composed of num events where
  # these are composed of featured events and non-featured events
  def self.highlights(num)
    featured = self.featured_events
    if featured.size < num
      non_featured = self.non_featured_events + self.current_non_weekly
      # we need to sort because we're adding the non_weeklies to the end of the non-featured set
      highlights = (featured + non_featured.sort.take(num - featured.size))
      highlights.uniq.sort
    else
      featured.sort
    end
  end

  # The repeating events that are occurring this week
  def self.repeating_this_week
    self.coming
      .in_series
      .published
      .this_week
      .not_started
      .ordered
  end

  # Return Event object given a Date, Time, Time, attribute Hash
  def self.from_date_and_times(date, start_time, end_time, attributes)
    event_start = DateTime.new(date.year, date.month, date.day, start_time.hour, start_time.min, 0, start_time.zone)
    event_end = DateTime.new(date.year, date.month, date.day, end_time.hour, end_time.min, 0, end_time.zone)
    Event.new(attributes.merge(start_time: event_start, end_time: event_end))
  end

  def to_schema
    {
      '@context': 'http://schema.org',
      '@type': 'Event',
      name: self.title,
      startDate: self.start_time.iso8601,
      endDate: self.end_time.iso8601,
      description: self.short_description,
      sameAs: self.link,
      location: self.location.to_schema,
      organizer: self.user.to_schema
    }
  end

end
