class Calendar

  attr_reader :events, :in_progress, :highlights, :weekly

  def initialize(events = Event.main_calendar)
    @events = events
    @highlights = Event.highlights(5)
    @weekly = EventSeries.repeating_by_day
  end

  # Accessor method - convert the days hash we use
  # internally into an array of day objects
  # sorted asc
  def days
    @days.values.sort {|x,y| x.date <=> y.date}
  end

  def self.for(object)
    events = object.events.coming
    Calendar.new(events)
  end

  # Special method to enable display of
  # hidden events on user's show page
  def self.with_hidden(object)
    events = object.events.future.ordered
    Calendar.new(events)
  end

  # Create an Array of Arrays consisting of the locations
  # present within this calendar, together with
  # their count e.g. [[myplace, 2], [yours, 1]]
  def self.filter_locations_for(events)
    return if events.empty?
    locations = {}
    events.each do |e|
      next unless e.location.present?
      if locations.has_key? e.location.display_name
        locations[e.location.display_name] += 1
      else
        locations[e.location.display_name] = 1
      end
    end
    locations.sort_by(&:last).reverse
  end

  # Create an Array of Arrays consisting of the locations
  # present within this calendar, together with
  # their count e.g. [[party, 2], [demo, 1]]
  def self.filter_categories_for(events)
    return if events.empty?
    categories = {}
    Category.categories_for(events).each do |cat|
     categories[cat['id']] = cat['num'].to_i
    end
    categories.sort_by(&:last).reverse
  end
end
