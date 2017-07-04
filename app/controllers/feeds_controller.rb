class FeedsController < ApplicationController

  layout false

  def rss
    @events = Event.all()
  end

end

