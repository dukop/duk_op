class EventSeries < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  has_many :events
  has_and_belongs_to_many :categories
  validates :title, :description, :location_id, :user_id, :categories,
            :day_array, :rule, :start_date, :start_time, :end_time, :expiry, presence: true

  # TODO: this duplicates functionality in Event.rb so it should be refactored, but modularization caused constant load errors
  has_attached_file :picture, styles: { original: '500x500>', thumb: '100x100>'}, default_url: 'images/:st'
  validates_attachment_content_type :picture, :content_type => /\Aimage/
  validates_attachment_file_name :picture, matches: [/png\Z/i, /jpe?g\Z/i]
  validates_with AttachmentSizeValidator, attributes: :picture, less_than:  3.megabytes

  after_create :cascade_creation, if: :persisted?
  after_update :cascade_update

  scope :expiring, -> { where('expiry <= ?', DateTime.now + 1.week).where('expiry >= ?', DateTime.now).ordered }
  scope :expired, -> { where('expiry < ?', DateTime.now).ordered }
  scope :ordered, -> { order(expiry: :asc )}
  scope :expiring_warning_not_sent, -> { where(expiring_warning_sent: false) }
  scope :expired_warning_not_sent, -> { where(expired_warning_sent: false) }
  # the name method is an alias used
  # by the page title helper
  def name
    title
  end

  # We use these methods as proxies to the days field
  # so that we can store array data as strings and not
  # worry about SQL level compatibility issues.
  def day_array
    days.split(',') if days.present?
  end

  def day_array=(arr)
    self.days = arr.join(',')
  end

  def coming_events
    self.events.where('start_time > ? ', DateTime.now.to_formatted_s(:db))
  end

  # 1. update all existing events
  # 2. create new events - starting from the last existing event and ending at expiry
  def cascade_update
    return unless coming_events.present?
    coming_events.all.each do |event|
      
      start_time = DateTime.new(event.start_time.year, event.start_time.month, event.start_time.day, self.start_time.hour, self.start_time.min, 0, 0)
      end_time = DateTime.new(event.end_time.year, event.end_time.month, event.end_time.day, self.end_time.hour, self.end_time.min, 0, 0)

      # Timezone corrections: Use the timezone of the specific period of the
      # dates of the event.
      zone = TZInfo::Timezone.new('Europe/Copenhagen')
      start_period = zone.period_for_local(event.start_time).offset.utc_total_offset
      end_period = zone.period_for_local(event.end_time).offset.utc_total_offset

      # Subtract the offset because Rails will assume that it's UTC when storing
      # in the database. Setting offset=>1234 does *NOT* work
      start_time = start_time.advance(:seconds => -start_period)
      end_time = end_time.advance(:seconds => -end_period)
      
      event.update(event_attributes.merge(start_time: start_time, end_time: end_time))
    end
    date_last_existing = coming_events.order(:start_time).last.start_time.to_date
    create_events((date_last_existing + 1.day)) if expiry_changed?
  end

  # using rule, create events for this series
  def create_events(start_d)
    if rule == 'weekly'
      (start_d..expiry).each do |date|
        date_name = Date::DAYNAMES[date.wday]
        create_child(date) if date_name.in? day_array
      end
    elsif rule == 'biweekly_odd'
      (start_d..expiry).each do |date|
        date_name = Date::DAYNAMES[date.wday]
        if date_name.in? day_array
          if (date.cweek % 2) == 1
            create_child(date)
          end
        end
      end
    elsif rule == 'biweekly_even'
      (start_d..expiry).each do |date|
        date_name = Date::DAYNAMES[date.wday]
        if date_name.in? day_array
          if (date.cweek % 2) == 0
            create_child(date)
          end
        end
      end
    else
      # for each month, get the matching dates for each day specified using the rule specified
      dates_to_months(start_d, expiry).each do |month|
        cur_month = Date::MONTHNAMES[month]
        day_array.each do |day|
          day_as_date = convert_rule_to_date(rule, day, cur_month)
          create_child(day_as_date)
        end
      end
    end
  end

  def create_child(day_as_date)
    # day_as_date will be nil if Chronic can't parse it
    return if day_as_date.nil?
    # don't accept any dates prior to today or after expiry_d
    return if day_as_date < DateTime.now.to_date
    return if day_as_date > expiry
    return if day_as_date.in? child_dates

    # Hard-coded timezone
    zone = TZInfo::Timezone.new('Europe/Copenhagen')

    # Assume we have the right timezone at 10 AM
    when_dtm = DateTime.new(day_as_date.year, day_as_date.month, day_as_date.day, 10, 0, 0)
    # Fetch a UTC offset for that date
    when_offset = zone.period_for_local(when_dtm).offset.utc_total_offset

    # Subtract the offset because Rails will assume that it's UTC when storing
    # in the database. Setting offset=>1234 does *NOT* work
    start_time = self.start_time.advance(:seconds => -when_offset)
    end_time = self.end_time.advance(:seconds => -when_offset)
    
    child = Event.from_date_and_times(day_as_date, start_time, end_time, event_attributes)
    unless child.save
      logger.error "event could not be saved with rule #{rule} and date #{day_as_date}"
    end
  end

  def child_dates
    Event.where(event_series_id: self.id)
        .collect {|e| e.start_time.to_date }
  end


  # get the month numbers for the dates in question
  # e.g. from Date1 to Date2 -> [10,11,12,1]
  def dates_to_months(date1, date2)
    (date1..date2).to_a.collect(&:month).uniq
  end

  def cascade_creation
    create_events(start_date)
  end

  def short_description=(val)
    self.description = val
  end

  # Returns the series objects with
  # weekly events occurring this week
  def self.active_weekly
    self.where('start_date <= ?', DateTime.now)
        .where('expiry >= ?', DateTime.now)
        .includes(:categories)
        .includes(:location)
        .where("rule LIKE 'weekly'")
        .where(published: true)
        .order('categories.danish desc')
  end

  # Return a hash of days in the week with the
  # current series events grouped as values
  # e.g. { 'Monday' => [Event1, Event2], 'Wednesday' => ... }
  def self.repeating_by_day
    day_hash = {}
    Event.repeating_this_week.each do |event|
      start_date = event.start_time.to_date
      day_hash[start_date] = [] unless day_hash.has_key?(start_date)
      day_hash[start_date] << event
    end
    day_hash.transform_keys! { |date| date.strftime('%A') }
    day_hash.transform_values(&:sort) # sort events internally
  end

  private

  # Use Chronic to convert the rules to Date objects
  # in the case of the 'last' rule, we need to try the fifth followed by the fourth
  # if no date is found, it will return nil
  def convert_rule_to_date(rule, day, month)
    Rails.logger.info "CHRONIC:: #{rule} #{day} in #{month}"
    if %w{first second third}.include? rule
      Chronic.parse("#{rule} #{day} in #{month}").try(:to_date)
    elsif rule == 'last'
      Chronic.parse("fifth #{day} in #{month}").try(:to_date) || Chronic.parse("fourth #{day} in #{month}").try(:to_date)
    end
  end

  def event_attributes
    attributes.except(
        'id', 'expiry', 'days', 'rule', 'start_date', 'start_time', 'end_time',
        'picture_file_size', 'picture_content_type', 'picture_updated_at', 'picture_file_name',
        'expired_warning_sent', 'expiring_warning_sent'
    ).merge(event_series_id: self.id, categories: categories)
  end
end
