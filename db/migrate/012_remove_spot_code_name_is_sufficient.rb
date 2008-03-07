class RemoveSpotCodeNameIsSufficient < ActiveRecord::Migration
  def self.up
    remove_column :spots, :code
  end

  def self.down
    add_column :spots, :code, :string
  end
end
