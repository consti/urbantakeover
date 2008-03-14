class CreateStuffs < ActiveRecord::Migration
  def self.up
    create_table :stuffs do |t|
      t.column :name, :string
      t.column :spot_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :stuffs
  end
end
