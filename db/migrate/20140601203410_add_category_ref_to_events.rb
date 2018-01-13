class AddCategoryRefToEvents < ActiveRecord::Migration[4.2]
  def change
    add_reference :events, :category, index: true
  end
end
