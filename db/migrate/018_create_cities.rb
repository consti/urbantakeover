class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.column :name,       :string
      t.column :longitude,  :float   # geolocate on create
      t.column :latitude,   :float   # geolocate on create
      t.column :zoomfactor, :integer
      t.timestamps
    end
    
    add_column :users, :city_id, :integer
  end

  def self.down
    drop_table :cities
    remove_column :users, :city_id
  end
end
