class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends, id: :uuid do |t|
      t.string :name
      t.string :screen_name
      t.string :location
      t.float :latitude, {:precision=>10, :scale=>6}
      t.float :longitude, {:precision=>10, :scale=>6}
      t.integer :twitter_user_id
      t.uuid :user_id
      
      t.timestamps
    end
  end
end
