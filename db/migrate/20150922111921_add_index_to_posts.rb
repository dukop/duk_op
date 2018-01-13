class AddIndexToPosts < ActiveRecord::Migration[4.2]
  def change
  	add_index :posts, :featured
  end
end
