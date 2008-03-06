class StorefrontController < ApplicationController

  # GET /spots
  # GET /spots.xml
  def index
    @spots = Spot.find(:all)

    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)
    
    @recent_claims = Claim.find :all, :limit => 16, :order => "created_at desc"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spots }
    end
  end
end
