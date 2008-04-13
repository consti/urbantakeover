module TeamHelper
  def format_team team
    link_to(h(team.name), {:controller => :team, :action => :show_by_name, :name => team.name}, :class => 'team-name', :style => " border-left: 3px solid #{team.colour}")
  end
end