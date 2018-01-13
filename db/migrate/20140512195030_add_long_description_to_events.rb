class AddLongDescriptionToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :long_description, :text
    rename_column :events, :description, :short_description
  end
end
