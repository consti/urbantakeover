class AddSpotDescriptionText < ActiveRecord::Migration
  def self.up
    add_column :spots, :text, :text
  end

  def self.down
    remove_column :spots, :text
  end
end
