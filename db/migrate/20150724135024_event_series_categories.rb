class EventSeriesCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories_event_series, id: false  do |t|
      t.belongs_to :event_series, index: true
      t.belongs_to :category, index: true
    end
  end
end
