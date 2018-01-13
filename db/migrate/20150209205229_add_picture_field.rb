class AddPictureField < ActiveRecord::Migration[4.2]
  def change
    add_attachment :events, :picture
  end
end
