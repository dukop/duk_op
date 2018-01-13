class CreatePosts < ActiveRecord::Migration[4.2]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.boolean :featured

      t.timestamps null: false
    end
  end
end
