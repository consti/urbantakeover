class SpotAddAddress < ActiveRecord::Migration
  def self.up
    add_column :spots, :address, :string
  end

  def self.down
    remove_column :spots, :address
  end
end
