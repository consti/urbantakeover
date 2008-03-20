class AddCityToSpot < ActiveRecord::Migration
  def self.up
    add_column :spots, :city_id, :integer
    
    vienna = City.create :name => 'Wien', :longitude =>48.260341, :latitude => 16.372375, :zoomfactor => 14
    
    Spot.find(:all).each do |s|
      s.city = vienna
      s.save
    end
    
    User.find(:all).each do |u|
      u.city = vienna
      u.save
    end
  end

  def self.down
    remove_column :spots, :city_id
  end
end
