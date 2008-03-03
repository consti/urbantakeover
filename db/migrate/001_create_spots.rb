class CreateSpots < ActiveRecord::Migration
  def self.up
    create_table :spots do |t|
      t.column :name, :string
      t.column :code, :string
      t.column :geolocation_x, :float
      t.column :geolocation_y, :float # ie [75.6, -42.467]
      t.timestamps
    end
  end

  def self.down
    drop_table :spots
  end
end
