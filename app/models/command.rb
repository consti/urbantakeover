class Command < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :text
  validates_presence_of :source
  belongs_to :user
  
  def self.run_for user, command, source="web"
    c = Command.create :user => user, :text => command, :source => source
    c.run!
  end
  
  def h
    help
  end  
  def allowed_commands
    self.methods - ['run!']
  end

  def run!
    command, arguments = self.text.downcase.strip.split(" ", 2)
    arguments ||= "" # if not set in split
    return self.send(command, arguments) if allowed_commands.include? command

    #per default: treat as claim and/or feature request. eg: "d cbo metalab @ rathausstraÃŸe 6"
    admin_user = User.find_by_login "oneup"
    admin_user.notify_mail "[UTO feature]: #{self.text} by #{user.name}" if admin_user

    #try this anyway
    return claim(arguments)      
  end  

  def help what
    user.notify_all("Commands: " + ["'claim spotname'", "'claim spot @ address, city'", "'team teamname'","'help'", "'friend friendname'"].join("\n"))
  end

  def hi arguments
    user.notify_all "ohai, i'm the urbantakeover bot. send 'd cpu claim spot @ address, city' to mark something claimed."
  end
  
  def friend friend_name
    friend = User.find_by_login(friend_name)

    unless friend
      return user.notify_all("lol! no user #{friend_name} found.")
    end

    if (friend != self.user) and (not friend.friend_of? self.user)
      self.user.friends << friend
      self.user.save!
      friend.score 50, "added as friend by #{user.login}"
      return user.notify_all("yay! added #{friend.login} as friend")
    else
      return user.notify_all("sry, already friends with #{friend.login}")
    end
  end
  
  # TODO alias method me  
  def claimed spot_description
    claim spot_description
  end
  
  def claiming spot_description
    claim spot_description
  end
  # TODO END

  def claim spot_description
    if spot_description.include? "@"
      s = spot_description.split("@")
      spot_name = s[0].strip.downcase
      spot_address = s[1].strip.downcase
      return claim_by_name_and_address(spot_name, spot_address)
    else
      target = spot_description.downcase
      return claim_by_name_or_address(target)
    end
  end
  
  def team team_name
    team = Team.find_or_create_by_name team_name
    if not team.users.include? user
      team.users << user
      if team.save
        return user.notify_all("BAM! joined team #{team.name}")
      else
        err = team.errors.full_messages.join(', ')
        return user.notify_all("sry, can't join team #{team.name}? #{err}")
      end
    else
      return user.notify_all("huh? you're already in team #{team.name}!")
    end
  end

  def buff args
    user_name, spot_name = args.split("@")
    user_name.strip!
    spot_name.strip!
    
    buff_user = User.find_by_name user_name
    spot = Spot.find_by_name spot_name
    
    if (not buff_user) or (not spot)
      return user.notify_all("huh? no user #{user_name} or spot #{spot_name} found.")
    end
    
    buff_user_claim = spot.claims.find :first, :conditions => ['user_id = ?', buff_user.id], :order => "created_at DESC"
    return user.notify_all("huh? user #{buff_user.name} is not at #{spot.name}!") unless buff_user_claim
    
    buff_user_claim.destroy
    buff_user.score -100, "buffed by #{user.name} @ #{spot.name}"
    user.score 0, "buffed #{buff_user.name} @ #{spot.name}"
  end

private
  #TODO: refactor me
  #TODO: space indicates possible address ;)
  def claim_by_name_or_address target
    spot_name = target
    spot = Spot.find_by_name spot_name
    unless spot
      #maybe it's an address:
      address = target
      address += ", #{user.city.name}" unless address.include? "," # indicates a spot with a city

      geocodes = Geocoding.get(address)
      if geocodes.empty?
        spot = Spot.create_by_tupalo target

        if not spot
          # no tupalo spot, must have really been an address
          user.notify_all "sec, need address for #{spot_name}. plz send 'claim #{spot_name} @ address'."
          return "sec, need address for #{spot_name}. plz send 'claim #{spot_name} @ $address'."      
        end
      elsif geocodes.size > 1
        user.notify_all "plz write exact address, multiple spots found. like #{geocodes.first.address}"
        return "sry, multiple spots found. for #{address}. eg: #{geocodes.first.address}."
      else
        geocode = geocodes.first
        spot = Spot.find_by_address geocode.address
        unless spot
          spot = Spot.create :name => spot_name, :address => geocode.address, :geolocation_x => geocode.latitude, :geolocation_y => geocode.longitude
          spot.save
        end
      end
    end
    
    unless user.can_claim? spot
      user.notify_all "lol, you already own #{spot.name}!"
      return "you already own #{spot.name}"
    end
    
    user.claim spot
    return "BAM! claimed #{spot.name}"
  end

  def claim_by_name_and_address spot_name, spot_address
    #default: try to tag address
    address = spot_address
    address += ", #{user.city.name}" unless address.include? "," # indicates a spot with a city

    geocodes = Geocoding.get(address) # HARHAR - users can easily find their own stuffz
    if geocodes.empty?
      user.notify_all "plz: claim like '#{spot_name} @ Doestreet 12, City'"
      return "no address found for '#{address}'"
    elsif geocodes.size > 1
      user.notify_all "plz write exact address, multiple spots found. eg: #{geocodes.first.address}"
      return "sry, multiple spots found. for #{address}"
    else
      geocode = geocodes.first
      spot = Spot.find_by_address geocode.address
      unless spot
        spot = Spot.create :name => spot_name, :address => geocode.address, :geolocation_x => geocode.latitude, :geolocation_y => geocode.longitude
        spot.save
        self.user.claim spot
        return  "#{self.user.name} conquered a new spot! #{spot_name} @ #{spot.address}"
      end
      
      #reclaim an existing spot
      #TODO: save old name, so we see how names change
      if spot.name != spot_name
        old_name = spot.name
        stuff = Stuff.create :name => spot.name, :spot => spot # save old name for spot
        spot.name = spot_name
        spot.save
      end

      if self.user.can_claim? spot
        claim = self.user.claim spot
        if old_name
          return user.notify_all("lol! you rebranded #{old_name} to #{spot.name}!")
        else
          return user.notify_all("bam! 10 points for claiming #{spot.name}")
        end
      else
        return user.notify_all("lol! #{spot.name} is already yours!")
      end
    end
  end  
end