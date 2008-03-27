class AddFlickrToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :flickr, :string
  end

  def self.down
    add_column :users, :flickr, :string
  end
end
