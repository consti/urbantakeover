class SpotToSpotOrAddress < ActiveRecord::Migration
  def self.up
    add_column :spots, :spot_id, :integer
  end

  def self.down
    remove_column :spots, :spot_id
  end
end
