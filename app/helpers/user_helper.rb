module UserHelper
  def format_user user
    style = "background-color: #{user.colour_1};"
    if user.team
      style += " border-color: #{user.team.colour};"
    end
    
    if user.colour_2
      style += " color: #{user.colour_2};"
    end

    link_to(h(user.login), {:controller => :user, :action => :show, :id => user}, :class => 'user-name', :style => style)
  end
end