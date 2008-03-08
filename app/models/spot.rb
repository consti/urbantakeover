class Spot < ActiveRecord::Base
  validates_presence_of :geolocation_x
  validates_presence_of :geolocation_y
  validates_presence_of :name
  
  has_many :claims, :order => "created_at DESC"


  #todo: turn me into a before_save filter
  before_validation :geolocate_address
  
  
  def geolocate_address
    return if not self.address or self.address.empty?
    
    geocode = Geocoding.get(self.address)
    return if geocode.empty? # wenn mehrere gefunden, die erstbeste nehmen!
    self.geolocation_x = geocode[0][:latitude]
    self.geolocation_y = geocode[0][:longitude]
  end

  def geolocation
    return [geolocation_x, geolocation_y]
  end
  
  def geolocation=(x, y=nil)
    if Array == x
      geolocation_x, geolocation_y = x
    else
      geolocation_x = x
      geolocation_y = y
    end
  end

  def geolocation_text
    "%d %d" % [geolocation_x, geolocation_y]
  end
  
  def geolocation_text= (value)
    geolocation_x, geolocation_y = value.split(" ", 2)
  end
  
  def current_claim
    #todo: store in database to avoid this freaking query
    self.claims.find :first
  end
  
  def current_owner
    current_claim.user if current_claim
  end
  
  # returns the claim that "crossed" the passed claim
  # TODO: make more performant? (used in claims/my)
  def first_claim_after claim
    self.claims.find :first, :order => "created_at ASC", :conditions => ["created_at > ?", claim.created_at]
  end
  
  def first_claim_before claim
    self.claims.find :first, :order => "created_at DESC", :conditions => ["created_at < ?", claim.created_at]
  end
end
