class RemoveCategoryFieldFromEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :category, :string
  end
end
