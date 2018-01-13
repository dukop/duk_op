class AddIsAnonFieldToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_anonymous, :boolean, default: false
  end
end
