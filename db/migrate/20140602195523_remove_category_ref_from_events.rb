class RemoveCategoryRefFromEvents < ActiveRecord::Migration[4.2]
  def change
    remove_reference :events, :category
  end
end
