class TwitterFriendWith < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_friend_with, :string
  end

  def self.down
    remove_column :users, :twitter_friend_with
  end
end
