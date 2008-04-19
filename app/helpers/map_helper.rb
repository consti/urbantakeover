module MapHelper
  def get_map_data(spots=nil)
    spots ||= Spot.find(:all)

    map = GMap.new("map")
    map.control_init(:large_map => true, :map_type => true)
    
    return spots, map
  end
  
  def show_map spots=nil
    render :partial => 'map/view', :locals => {:spots => spots}
  end

  def show_small_map spots=nil
    render :partial => 'map/view_small', :locals => {:spots => spots}
  end
  
  def show_wide_map spots=nil
    render :partial => 'map/view_wide', :locals => {:spots => spots}
  end
  
end
