module MapHelper
  def get_map_data(spots=nil)
    spots ||= Spot.find(:all)

    map = GMap.new("map")
    map.control_init(:large_map => true, :map_type => true)
    
    return spots, map
  end
end
