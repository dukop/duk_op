class AdminController < ApplicationController
  layout 'single_card'
  before_action :authenticate_user!, only: [:dashboard]
  before_action :admin_user?, only: [:dashboard]

  SORT_TYPES = ['created_at', 'updated_at']

  def dashboard
    @sort = params[:sort].in?(SORT_TYPES) ? params[:sort]: 'created_at'
    @events = Event.future.order(@sort => :desc)
  end

  def series
    @expiring = EventSeries.expiring
    @expired = EventSeries.expired
  end

  def analytics
    @grouped_action = AnalyticsService.group_by(:name)
    @events = AnalyticsService.events_created
  end

  def events
    @start_date, @end_date = parse_event_dates
    @timeseries = AnalyticsService.events_created('week', @start_date, @end_date)
  end

  def parse_event_dates
    if params[:start_date].present?
      start_d = Date.new(start_date[:year], start_date[:month], start_date[:day])
    else
      start_d = Date.today - 2.months
    end
    if params[:end_date].present?
      end_d = Date.new(end_date[:year], end_date[:month], end_date[:day])
    else
      end_d = Date.today + 1.day
    end
    [start_d, end_d]
  end

  def timeseries
    @interval = params[:interval] || 'week'
    @view = params[:view] || 'total'
    @timeseries = AnalyticsService.time_series(@view, @interval)
  end

  def admin_user?
    unless current_user.is_admin?
      redirect_to denied_path, notice: 'Only for admin users'
    end
  end

  def denied_path
    stored_location_for(current_user) || root_path
  end

  def start_date
    params.require(:start_date).permit(:day, :month, :year).transform_values(&:to_i)
  end

  def end_date
    params.require(:end_date).permit(:day, :month, :year).transform_values(&:to_i)
  end
end
