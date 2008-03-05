class AddUserColours < ActiveRecord::Migration
  def self.up
    add_column :users, :colour_1, :string, :limit => 16
    add_column :users, :colour_2, :string, :limit => 16
    add_column :users, :colour_3, :string, :limit => 16
  end

  def self.down
    remove_column :users, :colour_1
    remove_column :users, :colour_2
    remove_column :users, :colour_3
  end
end
