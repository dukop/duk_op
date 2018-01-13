class UpdateSeries < ActiveRecord::Migration[4.2]
  def change
    remove_column :event_series, :start_time, :datetime
    remove_column :event_series, :end_time, :datetime
    add_column :event_series, :rule, :string
    add_reference :events, :event_series, index: true
  end
end
