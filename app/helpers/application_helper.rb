# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_interval(timestamp)
    
    granularity = 1
    units =   [ ['year', 31536000],
                ['week', 604800],
                ['day', 86400],
                ['hour', 3600],
                ['min', 60],
                ['second', 1] ]
    output = '';
    
    for unit in units
      if timestamp >= unit[1]
        count = (timestamp / unit[1]).floor
        output += pluralize(count, unit[0]) + ' '
        timestamp %= unit[1]
        granularity -= 1
      end
      
      break if granularity == 0
    end
    
    output.empty? ? '0 seconds' : output.strip
  end
  
  def interval_to_now timestamp
    return "#{format_interval(Time.now - timestamp)} ago"
  end
  
  def print_pwnzing_logo
    # the closer we get to OVER NINETHOUSAND the moar characters are green
    name = "urbantakeover"
    score_goal = 9000
    
    points_per_character = 9000/name.length
    
    green_percentage_character_count = (Claim.count/points_per_character).floor
    fancy_name = '<span class="green">%s</span>%s' % [name[0...green_percentage_character_count], name[green_percentage_character_count,name.length]]
    if Claim.count < score_goal
      fancy_name + "<!-- #{Claim.count} < nine thousand (props @ diemade)-->"
    else
      fancy_name + "FUCK YEAH => OVER NINE THOUSAND!!! (PWND DIE MADE)"
    end
  end
  
  def todo what
    '<p class="todo">%s <a href="mailto://team@72dpiarmy.com">mail us if this is important to you</a></p>' % what
  end
end
