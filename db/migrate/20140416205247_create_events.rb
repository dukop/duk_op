class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.text :location
      t.datetime :start_time
      t.datetime :end_time
      t.string :category
      t.string :creator

      t.timestamps
    end
  end
end
