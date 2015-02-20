class Friend < ActiveRecord::Base

  belongs_to :user
  geocoded_by :location

  def self.get_friend_data(friend, location_value, user_id)
    self.create_with(
      name: friend.name,
      location: friend.location,
      latitude: location_value.first,
      longitude: location_value.second).find_or_create_by(
      user_id: user_id, screen_name: friend.screen_name)
  end


end
