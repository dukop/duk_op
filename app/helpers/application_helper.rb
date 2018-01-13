module ApplicationHelper

  # Attempt to build the best possible page title.
  # If there is an action specific key, use that (e.g. users.index).
  # If there is a name for the object, use that (in show and edit views).
  # Worst case, just use the app name
  def page_title
    app_name = t :app_name
    action = t("titles.#{controller_name}.#{action_name}", default: '')
    action += " #{object_name}" if object_name.present?
    action += " - " if action.present?
    "#{action} #{app_name}"
  end

  # try and get a name using the name, display name or language method
  # return nil if nothing works
  def object_name
    assigned_object.try(:display_name) || assigned_object.try(:name) || assigned_object.try(t :language)
  end

  def assigned_object
    assigns[controller_name.singularize]
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def username(user)
    if user.is_anonymous?
      t('anonymous_user.name')
    else
      user.username
    end
  end

  def own_page?(user)
    current_user && (current_user == user)
  end

  def no_index_rule
    content_for :meta_tags do
      '<meta name="robots" content="noindex">'.html_safe
    end
  end

  def user_metadata(user)
    concat(schema_json(user))
    concat("\n")
    concat(rss_link(user))
    concat("\n")
  end

  def rss_link(user)
    auto_discovery_link_tag(:rss, { format: :rss }, { title: "Feed for user #{user.username}" })
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end
end
