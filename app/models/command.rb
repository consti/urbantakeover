class Command < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :text
  belongs_to :user
  
  def run!
    parts = self.text.strip.split(" ")
    parts[0].downcase!
    # claim spot_name [@ addresse]
    if parts[0] == "claim"
      return claim_spot(parts[1, parts.size].join(" ")) #spot beschreibung wieder zusammensetzen

    elsif parts[0] == 'friend'
      return add_friend(parts[1, parts.size].join(" "))

    elsif parts[0] == 'team'
      return join_team( parts[1, parts.size].join(" "))
        
    elsif parts[0] == 'cross'
      return "not implemented yet fully und so"

      return cross_spot(parts[1, parts.size].join(" "))
    elsif (parts[0] == 'h') or (parts[0] == 'help')
      return ["'claim spotname'", "'claim spot @ address'", "'team teamname'","'help'"].join("\n")
    else
      #per default: treat as claim. eg: "d cbo metalab @ rathausstraße 6"
      return claim_spot(parts.join(" "))
    end
      
  end

private
  def add_friend friend_name
    friend = User.find_by_login(friend_name)
    if (friend != self.user) and (not friend.friend_of? self.user)
      self.user.friends << friend
      self.user.save!
      user.score 50, "added #{friend.login} as friend"
      friend.score 50, "added as friend by #{user.login}"
      return "BAM! 5 points for adding #{friend.login} as friend" #TODO: send sms to user when .score!
    else
      user.notify_twitter "sry, already friends with #{friend.login}"
      return "SRY, Already friends with #{friend.login}!"
    end
  end
  
  def claim_spot spot_description
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
  
  def claim_by_name_or_address target
    spot_name = target
    spot = Spot.find_by_name spot_name
    unless spot
      #maybe it's an address:
      address = target
      address += ", #{user.city}" if user.city # TODO: make city omitable if i'm somewhere else

      geocodes = Geocoding.get(address)
      if geocodes.empty?
        user.notify_twitter "sec, need address for #{spot_name}. plz send 'claim #{spot_name} @ address'."
        return "sec, need address for #{spot_name}. plz send 'claim #{spot_name} @ $address'."      
      elsif geocodes.size > 1
        user.notify_twitter "plz write exact address, multiple spots found. like #{geocodes.first.address}"
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
      user.notify_twitter "lol, you already own #{spot.name}!"
      return "you already own #{spot.name}"
    end
    
    user.claim spot
    return "BAM! claimed #{spot.name}"
  end

  def claim_by_name_and_address spot_name, spot_address
    #default: try to tag address
    address = spot_address
    address += ", #{user.city}" if user.city # TODO: make city omitable if i'm somewhere else

    geocodes = Geocoding.get(address) # HARHAR - users can easily find their own stuffz
    if geocodes.empty?
      user.notify_twitter "plz: claim like '#{spot_name} @ Musterstraße 12'"
      return "no address found for '#{address}'"
    elsif geocodes.size > 1
      user.notify_twitter "plz write exact address, multiple spots found. like #{geocodes.first.address}"
      return "sry, multiple spots found. for #{address}"
    else
      geocode = geocodes.first
      spot = Spot.find_by_address geocode.address
      unless spot
        spot = Spot.create :name => spot_name, :address => geocode.address, :geolocation_x => geocode.latitude, :geolocation_y => geocode.longitude
        spot.save
        self.user.claim spot
        return "#{self.user.name} conquered a new spot! #{spot_name} @ #{spot.address}"
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
          user.notify_twitter "lol! you rebranded #{old_name} to #{spot.name}!"
          return "bam! 10 points for claiming #{spot.name} (renamed from #{old_name})"
        else
          # TODO: previous user get points for giving this a good name
          return "bam! 10 points for claiming #{spot.name}"
        end
      else
        user.notify_twitter "lol! #{spot.name} is already yours!"
        return "#{spot.name} already belongs to #{user.name}" # TODO: update me if there are new conditions
      end
    end
  end
  
  def join_team team_name
    team = Team.find_or_create_by_name team_name
    if not team.users.include? user
      team.users << user
      if team.save
        return "BAM! joined team #{team.name}"
      else
        err = team.errors.full_messages.join(', ')
        user.notify_twitter "sry, can't join team #{team.name}? contact team@72dpiarmy.com plz!"
        return "sry, can't join team #{team.name}? #{err}"
      end
    else
      user.notify_twitter "huh? you're already in team #{team.name}!"
      return "huh? you're already in team #{team.name}!"
    end
  end

  def cross_spot spot_description
    if not spot_description.include? "@"
      return "must tell where you crossed #{spot_description}. ie 'crossed oneup @ metalab'"
    end
    
    s = spot_description.split("@")
    user_name = s[0].strip.downcase
    spot_name_or_address = s[1].strip.downcase
    
    user = User.find_by_login user_name
    unless user
      return "no user called #{user_name}, sorry can't cross."
    end

    spot = Spot.find_by_name(spot_name_or_address)
    unless spot
      geocodes = Geocoding.get(spot_name_or_address)
      if geocodes.empty?
         return "sorry, can't understand address #{spot_address}"
      elsif geocodes.size > 1
         return "multiple addresses found, specify address exactly. eg #{geocodes.first.address}"
      else
         geocode = geocodes.first
         spot = Spot.find_by_address geocode.address
         unless spot
           return "no spot found at adress #{geocode.address}, can't cross #{user.login} there!"
         end
      end
    end
    
    if user.can_claim? spot
      #TODO: notify old user (also with just re-claiming)
      user.claim spot
      return "yay, snatched spot from #{user.login}!"  
    else
      return "can't cross yourself!"
    end
  end
end
