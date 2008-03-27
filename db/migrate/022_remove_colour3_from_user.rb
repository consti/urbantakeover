class RemoveColour3FromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :colour_3
  end

  def self.down
    add_column :users, :colour_3, :string, :limit => 16
  end
end
