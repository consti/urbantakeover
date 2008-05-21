module FormatHelper
  def format_city city
    link_to(h(city.name), {:controller => :city, :action => :show, :id => city}, :class => 'city-name')
  end

  def format_team team
    link_to(h(team.name), {:controller => :team, :action => :show, :id => team}, :class => 'team-name', :style => " border-left: 3px solid #{team.colour}")
  end
  
  def format_spot spot
    link_to(h(spot.name), {:controller => :spot, :action => :show, :id => spot}, :class => 'spot-name')
  end
  

  def format_list entries
    if entries.empty?
      return "Oh noes - none!"
    end
    
    formatter = "format_#{entries.first.class.to_s.downcase}"
    
    lilili = entries.map {|entry| content_tag("li", eval("#{formatter}(entry)")) }
    return content_tag "ul", lilili
  end
end