class AddCitiesAwareness < ActiveRecord::Migration
  def self.up
    city_seventeen = City.find_by_name "City 17"
    unless city_seventeen
      city_seventeen = City.new :name => "City 17", :longitude => 0, :latitude => 0
      city_seventeen.save! # this is the city if we find no city for you
    end
    
    Spot.find(:all).each do |spot|
      
      if spot.address.nil? # spot has NO ADDRESS
        spot.city = city_seventeen
        print "city for spot without address.... "
      else
        print "city for spot @ #{spot.address}... "
        sleep 0.2
        gc = Geocoding.get(spot.address)
        if gc.size == 0 # spot has INCORRECT ADDRESS (a different city, so we can make an admin interface to correct those later)
          print "no geocoding found ... "
          spot.city = city_seventeen
        else
          location = gc.first
          city = City.find_or_create_by_name location.locality

          if city.save # sometimes we get b0rked localities
            print "by geolocation ... "
            spot.city = city
          else
            print "INVALID LOCALITY - #{location.locality} ... "
            spot.city = city_seventeen
          end
        end
      end
      print "#{spot.city.name} ... "      
      spot.save!
      print "then #{spot.city.name}\n"
    end

    User.find(:all).each do |user|
      # guess users city from last claim or use vienna

      print "city for user #{user.name}... "
      if user.claims.empty?
        user.city = city_seventeen
      else
        user.city = user.claims[0].spot.city
      end
      
      if user.city.nil?
        user.city = city_seventeen
      end

      user.save!
      print "#{user.city.name}... "
      #user.notify_all "we added different cities to urbantakeover and set yours to #{user.city.name}. you can change this on http://urbantakeover.at/preferences. have a nice day!"
      print "notified user!\n"
    end
  end

  def self.down
    execute "UPDATE spots set city_id=null"
    execute "UPDATE users set city_id=null"
  end
end
