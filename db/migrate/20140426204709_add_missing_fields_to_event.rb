class AddMissingFieldsToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :price, :string
    add_column :events, :cancelled, :boolean
  end
end
