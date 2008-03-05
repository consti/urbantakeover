class StorefrontController < ApplicationController

  # GET /spots
  # GET /spots.xml
  def index
    @spots = Spot.find(:all)

    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)

    unless @spots.empty?
      @map.center_zoom_init(@spots[-1].geolocation, 13)  # zoom to last spot

      @spots.each do |spot|
        marker = GMarker.new(spot.geolocation,
          :title => spot.name, :info_window => "<strong>%s</strong><br/>SMS Code: %s<br/>claimed by: %s" % [spot.name, spot.code, spot.current_owner ? spot.current_owner.login : "no one"])  
          @map.overlay_init(marker)
        
        #A) radius around spots
        @map.overlay_init(GPolygon.new(circle_points(spot.geolocation_x, spot.geolocation_y, 0.005), "#00ff00", 0, 0.5, "#0000ff", 0.5))
        #/A
        
        if params[:focus] and params[:focus] == spot.code
          @map.center_zoom_init(spot.geolocation, 13)  # zoom to last spot
        end
      end
      
      #B) polygon sets for players
      sets = {}
      @spots.each do |spot|
        sets[spot.current_owner] ||= []
        sets[spot.current_owner] << spot
      end
      
      sets[nil] = nil
      sets.each do |owner, spots|
        next if owner == nil
        polygon = GPolygon.new(spots.collect {|s| s.geolocation})
        polygon.opacity = 0.3
        polygon.stroke_color = [1,1,1,]
        polygon.stroke_opacity = 0.0
        polygon.color = "#00ff00"
        @map.overlay_init(polygon)
      end
      #/B
    end
    
    @recent_claims = Claim.find :all, :limit => 32, :order => "created_at desc"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spots }
    end
  end
  
  def circle_points(center_x, center_y, radius, quality = 3)

    points = []
    radians = Math::PI / 180

    0.step(360, quality) do |i|
      x = center_x + (radius * Math.cos(i * radians))
      y = center_y + (radius * Math.sin(i * radians))
      points << [x,y]
    end
    points
  end
end
