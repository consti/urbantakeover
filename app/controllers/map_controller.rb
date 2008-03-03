class MapController < ApplicationController

  def index
    @map = GMap.new("map")  
    @map.control_init(:large_map => true, :map_type => true)  
    @map.center_zoom_init([75.5,-42.56], 4)  

    marker = GMarker.new([75.6, -42.467],   
      :title => "Where Am I?", :info_window => "Hello, Greenland")  
    @map.overlay_init(marker)
  end
end