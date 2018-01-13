class CreateEventSeries < ActiveRecord::Migration[4.2]
  def change
    create_table :event_series do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :price
      t.boolean :cancelled
      t.integer :user_id
      t.integer :location_id
      t.boolean :comments_enabled
      t.string :link
      t.string :picture_file_name
      t.string :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_updated_at

      t.timestamps
    end

    create_table :event_series_categories, id: false  do |t|
      t.belongs_to :event_series, index: true
      t.belongs_to :category, index: true
    end
  end
end
