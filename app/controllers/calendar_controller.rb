class CalendarController < ApplicationController
  def index
    @calendar = Calendar.new
    @sorted = @calendar.events.group_by {|e| e.start_time.to_date }
  end
end
