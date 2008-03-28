module SpotsHelper
  def format_spot spot
    link_to(h(spot.name), {:controller => :spots, :action => :show_by_name, :name => spot.name}, :class => 'spot-name')
  end
end