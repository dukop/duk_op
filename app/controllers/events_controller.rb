class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :set_presenter, only: [:show]
  #TODO: shouldn't we authenticate the user before the create action also?
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :authorised_user?, only: [:edit, :update, :destroy]

  def show
  end

  def new
    @event = Event.new
  end

  def create
    event_params = user_params
    # add the user id if we've got one
    event_params.merge!(user_id: current_user.id) if user_signed_in?
    # handle creation of recurring events here
    if params[:recurring] == 'yes'
      series_params = event_params.merge(event_params[:event_series]).except(:event_series, :featured)
      @event_series = EventSeries.new(series_params)
      saved = @event_series.save
      notice = I18n.t('event_series.created', link: url_for(@event_series), num_events: @event_series.coming_events.size)
    else
      @event = Event.new(event_params.except('event_series'))
      saved = @event.save
      notice = I18n.t('events.event_created', link: url_for(@event))
    end

    respond_to do |format|
      if saved
        format.html { redirect_to root_path, notice: notice }
        format.json { render action: 'show', status: :created, location: @event }
      elsif @event_series.present?
        format.html { render template: 'event_series/new' }
        format.json { render json: @event_series.errors, status: :unprocessable_entity }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(user_params)
        destroy_image?
        format.html {
          redirect_to root_path, notice: I18n.t('events.event_updated', link: url_for(@event))
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: I18n.t('events.event_deleted') }
      format.json { head :no_content }
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_presenter
    @event_presenter = EventPresenter.new(@event, view_context)
  end

  def authorised_user?
    unless current_user.can_edit? @event
      redirect_to root_path, alert: I18n.t('general.permission_denied')
    end
  end

  # if the obj has a picture but it's not in the new form
  def destroy_image?
    if @event.picture.present? && params[:remove_picture] == '1'
      @event.picture.clear
      @event.save
    end
  end

  def user_params
    params.require(:event).permit(:title, :short_description, :long_description,
                                 :start_time, :end_time,  :location_id, :comments_enabled,
                                 :price, :cancelled, :link, :picture, :featured, :published,
                                 category_ids: [], event_series: [[:rule, :start_date, 
                                 :start_time, :expiry, :end_time, day_array: []]]).tap do |list|
      list[:category_ids].uniq!
      list[:event_series][:days] = list[:event_series][:day_array].select(&:present?).join(',') if list[:event_series].present? && list[:event_series][:day_array].present?
      list.delete(:featured) unless current_user.is_admin? # only admins can update featured value
    end
  end
end
