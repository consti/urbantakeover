class AddTupaloLink < ActiveRecord::Migration
  def self.up
    add_column :spots, :tupalo_link, :string
  end

  def self.down
    remove_column :spots, :tupalo_link
  end
end
