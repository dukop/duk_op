class RemoveCreatorFromEvent < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :creator
  end
end
