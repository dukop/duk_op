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

  def object_name
    assigns[controller_name.singularize].name rescue nil
  end

  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end
end
