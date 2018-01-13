class UpdateEventSeries < ActiveRecord::Migration[4.2]
  def change
  	add_column :event_series, :days, :string
  	add_column :event_series, :expiry, :datetime
  end
end
