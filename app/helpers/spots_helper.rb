module SpotsHelper
  def format_spot spot
    link_to(h(spot.name), {:controller => :spot, :action => :show, :id => spot}, :class => 'spot-name')
  end
end