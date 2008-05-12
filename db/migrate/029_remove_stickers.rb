class RemoveStickers < ActiveRecord::Migration
  def self.up
    CreateStickers.down
  end

  def self.down
    CreateStickers.up
  end
end
