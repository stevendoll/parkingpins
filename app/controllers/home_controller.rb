class HomeController < ApplicationController




  def index

    @friends = fetch_friend_data

    # self.get_friend_data(friend,location_value,user_id)
    @friends.each do |f|
      location = f.location

      location_value = Geocoder.coordinates("#{location}")
      if location_value.present?
        Friend.get_friend_data(f,location_value,current_user.id)
      end
    end

    puts @friends
  end

private
  def fetch_friend_data
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_key
      config.consumer_secret     = Rails.application.secrets.twitter_secret
      config.access_token        = "#{current_user.twitter_oauth_token}"
      config.access_token_secret = "#{current_user.twitter_oauth_secret}"
    end

    client.friends.take(20)

  end

end
