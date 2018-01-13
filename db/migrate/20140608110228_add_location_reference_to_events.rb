class AddLocationReferenceToEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :location, :text
    add_reference :events, :location, index: true
  end
end
