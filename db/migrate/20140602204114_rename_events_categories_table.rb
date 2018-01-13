class RenameEventsCategoriesTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :events_categories, :categories_events
  end
end
