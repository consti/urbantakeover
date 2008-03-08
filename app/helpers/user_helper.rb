module UserHelper
  def format_user user
    style = "background-color: #{user.colour_1};"
    if user.team
      style += " border-left: 3px solid #{user.team.colour}"
    end
    link_to(h(user.login), {:controller => :user, :action => :show, :id => user}, :class => 'user-name', :style => style)
  end
end