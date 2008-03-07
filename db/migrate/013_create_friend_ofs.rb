class CreateFriendOfs < ActiveRecord::Migration
  def self.up
    create_table 'user_friend', :id => false do |t|
      t.column :user_id,          :integer
      t.column :friend_id,        :integer
    end
  end

  def self.down
    drop_table 'user_friend'
  end
end
