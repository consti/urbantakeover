class AddTwitteruser < ActiveRecord::Migration
  def self.up
    add_column :users, :twittername, :string
  end

  def self.down
    remove_column :users, :twittername
  end
end
