module FormatHelper
  def format_buttons titles_urls
    titles_urls.compact! # sort out what became nil due to ifs
    return '' if titles_urls.empty?
    
    titles_urls = [titles_urls] unless titles_urls.first.is_a? Array # if we only pass one button
    
    '<ul class="buttons">' + 
    
    lis = titles_urls.collect do |title_url|
      title, url = title_url
      '<li>' + link_to(title, url) + '</li>'
    end.join("\n") +
    
    '</ul>'
  end  

  def format_city city
    link_to(h(city.name), {:controller => :city, :action => :show, :id => city}, :class => 'city-name')
  end

  def format_quest quest
    link_to(h(quest.name), quest, :class => 'quest-name')
  end

  def format_team team
    link_to(h(team.name), {:controller => :team, :action => :show, :id => team}, :class => 'team-name', :style => " border-left: 3px solid #{team.colour}")
  end
  
  def format_spot spot
    link_to(h(spot.name), {:controller => :spot, :action => :show, :id => spot}, :class => 'spot-name')
  end
  

  def format_list entries, params=nil
    if entries.empty?
      return "-"
    end
    
    formatter = "format_#{entries.first.class.to_s.downcase}"
    
    lilili = entries.map {|entry| content_tag("li", eval("#{formatter}(entry)")) }
    klass = "flat" if params == :flat
    return content_tag "ul", lilili, :class => klass
  end
  
  def format_navigation buttons
    '<div style="float: right">' +
        format_buttons(buttons) +
    '</div>'
  end
end