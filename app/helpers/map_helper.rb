module MapHelper
  def get_map_data(spots=nil)
    spots ||= Spot.find(:all)

    map = GMap.new("map")
    map.control_init(:large_map => true, :map_type => true)
    
    return spots, map
  end
  
  @@sizes = {
    :normal => [500, 400],
    :small => [500, 300],
    :wide => [1000, 300]
  }

  def show_map spots=nil, size=:normal
    width, height = @@sizes[size]
    render :partial => 'map/view', :locals => {:spots => spots, :width => width, :height => height}
  end  
end
