class AddLinkToLocation < ActiveRecord::Migration[4.2]
  def change
  	add_column :locations, :link, :string
  end
end
