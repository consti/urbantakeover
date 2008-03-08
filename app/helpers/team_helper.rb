module TeamHelper
  def format_team team
    link_to(h(team.name), {:controller => :team, :action => :show, :id => team}, :class => 'team-name', :style => " border-left: 3px solid #{team.colour}")
  end
end