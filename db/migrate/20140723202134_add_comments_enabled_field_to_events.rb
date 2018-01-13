class AddCommentsEnabledFieldToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :comments_enabled, :boolean, default: false
  end
end
