module UserHelper
  def format_user user
    link_to(h(user.login), {:controller => :user, :action => :show, :id => user}, :class => 'user-name', :style => "background-color: #{user.colour_1}")
  end
end