class Spot < ActiveRecord::Base
  validates_presence_of :geolocation_x
  validates_presence_of :geolocation_y
  validates_presence_of :name
  validates_presence_of :code
  
  has_many :claims

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
    self.claims.find :first, :order => "created_at DESC"
  end
  
  def current_owner
    current_claim.user if current_claim
  end
  
  # returns the claim that "crossed" the passed claim
  # TODO: make more performant? (used in claims/my)
  def first_claim_after claim
    self.claims.find :first, :order => "created_at DESC", :conditions => ["created_at > ?", claim.created_at]
  end
  
  def first_claim_before claim
    self.claims.find :first, :order => "created_at ASC", :conditions => ["created_at < ?", claim.created_at]
  end
end
