class Spot < ActiveRecord::Base
  validates_presence_of :geolocation_x
  validates_presence_of :geolocation_y
  validates_presence_of :name
  validates_presence_of :code
  
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
    print "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAH %f" % geolocation_x
  end
end
