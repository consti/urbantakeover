# to create a City, the name is sufficient
# everything else can be retrieved via Geocoding
#
# FUTURE: multiple names for the same city (eg: Vienna == Wien)

class City < ActiveRecord::Base
  has_many :users
  has_many :spots
  
  validates_presence_of :longitude
  validates_presence_of :latitude
  validates_uniqueness_of :name
  
  before_validation :geolocate

  def self.find_for_combobox
    self.find(:all, :order => "name")
  end
        	
  def geolocate
    return if self.longitude and self.latitude
    geocodes = Geocoding.get(self.name)
    if geocodes.size == 1
      geocode = geocodes.first
      self.longitude = geocode.longitude
      self.latitude = geocode.latitude
      #self.name = geocode.locality # dangerous... we need a fuzzy find_by_name !!! because city names != city.locality. ie: Vienna <=> Wien, Wien <=> Wien
    end
  end  
  
  def geolocation
    return [self.longitude, self.latitude]
  end
end
