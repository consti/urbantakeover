class UserScoresSeenUntil < ActiveRecord::Migration
  def self.up
    add_column :users, :scores_seen_until, :datetime
    
    User.find(:all).each do |user|
      user.scores_seen_until = Time.now
      user.save
    end
  end

  def self.down
    remoev_column :users, :scores_seen_until
  end
end
