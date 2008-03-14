class CreateTwittermessages < ActiveRecord::Migration
  def self.up
    create_table :twittermessages do |t|
      t.column :twitter_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :twittermessages
  end
end
