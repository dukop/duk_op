class AddFeaturedAttribute < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :featured, :boolean, default: false
    add_index :events, :featured
  end
end
