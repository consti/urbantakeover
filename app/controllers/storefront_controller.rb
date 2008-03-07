class StorefrontController < ApplicationController

  # GET /spots
  # GET /spots.xml
  def index    
    @recent_claims = Claim.find :all, :limit => 16, :order => "created_at desc"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spots }
    end
  end
end
