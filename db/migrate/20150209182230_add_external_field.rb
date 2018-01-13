class AddExternalField < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :link, :string
  end
end
