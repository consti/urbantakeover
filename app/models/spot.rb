require "hpricot"
require 'open-uri'

class Spot < ActiveRecord::Base
  validates_presence_of :geolocation_x
  validates_presence_of :geolocation_y
  validates_presence_of :name
  
  has_many :claims, :order => "created_at DESC", :dependent => :destroy
  has_many :stuffs, :dependent => :destroy
  belongs_to :city
  
  #has_many :spots # spots inside this spot
  #has_one :spot # parent spot


  #todo: turn me into a before_save filter
  before_validation :geolocate_if_necessary
  
  def self.create_by_tupalo name
    stuff = self.geolocate_from_tupalo name
    return nil if stuff.empty?
    longitude, latitude, tupalo_link = stuff
    return Spot.create(:name => name, :geolocation_x => longitude, :geolocation_y => latitude, :tupalo_link => tupalo_link)
  end
  
  def self.geolocate_from_tupalo name
    #tries to fetch the spot from tupalo
    begin
      doc = Hpricot(open("http://tupalo.com/vienna/search/#{CGI.escape(name)}.rss"))
    rescue
      #TODO: LOG ME!
      return nil # tupalo offline
    end

    items = (doc/"item")

    for item in items
      next unless (item/"title").text.downcase.starts_with? name.downcase
      
      location = (item/"georss:point").text
      longitude, latitude = location.strip.split(" ")
      tupalo_link = (item/"guid").text
    
      # todo: fetch address from tupalo wenn die scheiss idioten die gfickte dumme drecks api endlich hinbekommen scheiss inkompetenzler echt. warum muss man hier alles selber machen, geht gehts sterben tupalo deppen und überhaut!
      return [longitude.strip, latitude.strip, tupalo_link]
    end
    
    nil
  end

  def geolocate_if_necessary
    return if (not self.geolocation_x and not self.geolocation_y)
    unless self.address.empty?
      geocodes = Geocoding.get(self.address)
      unless geocodes.empty?
        self.geolocation_x = geocodes.first[:latitude]
        self.geolocation_y = geocodes.first[:longitude]
      end
    end
    
    unless self.name.empty?
      stuff = Spot.geolocate_from_tupalo name
      unless stuff.empty?
        longitude, latitude, tupalo_link = stuff
        self.geolocation_x = longitude
        self.geolocation_y = latitude
        self.tupalo_link = tupalo_link
      end
    end
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
  
  def is_editable_by? user
    (current_owner == user) or (user.is_admin?)
  end
end
