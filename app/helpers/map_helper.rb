module MapHelper
  def get_map_data(spots=nil)
    spots ||= Spot.find(:all)

    map = GMap.new("map")
    map.control_init(:large_map => true, :map_type => true)
    
    return spots, map
  end
  
  @@classes = {
    :normal => 'normal',
    :tall => 'tall',
    :small => 'small',
    :small_right => 'small right',
    :wide => 'wide'
  }

  def show_map spots=nil, c=:normal
    css_class = @@classes[c]
    render :partial => 'map/view', :locals => {:spots => spots, :css_class => css_class}
  end  
end
