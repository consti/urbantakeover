module UserHelper
  def format_user user
    style = "background-color: #{user.colour_1};"
    if user.team
      style += " border-color: #{user.team.colour};"
    end
    
    if user.colour_2
      style += " color: #{user.colour_2};"
    end

    link_to(h(user.login), {:controller => :user, :action => :show_by_name, :name => user.login}, :class => 'user-name', :style => style)
  end
  
  def format_score user
    return("%s points" % user.score.to_s) if user.team.nil?
    "%s/%s team points" % [user.score, user.team.score]
  end
end