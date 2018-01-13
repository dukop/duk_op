class AddPublishedFieldToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :published, :boolean, default: true
    add_column :event_series, :published, :boolean, default: true
  end
end
