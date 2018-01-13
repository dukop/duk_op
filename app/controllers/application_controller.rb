class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_posts

  after_action :track

  def self.default_url_options(options={})
    { locale: I18n.locale }
  end

  def set_posts
    @posts = Post.where(featured: true)
  end

  def after_sign_in_path_for(user)
    if user.is_admin?
      admin_dashboard_path
    else
      stored_location_for(:user) || root_path
    end
  end

  protected

  def track
    ahoy.track "#{controller_name}##{action_name}", request.filtered_parameters
  end
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :description, :email_confirmation])
  end

  def user_can_edit?(object)
    unless current_user.can_edit? object
      redirect_to root_path, alert: 'Only authorised users can edit events!'
    end
  end
end
