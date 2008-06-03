class SpotController < ApplicationController
  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :admin_only, :only => [:new, :create, :destroy]

  def admin_only
    current_user.is_admin?
  end

  # GET /spots
  # GET /spots.xml
  def index
    @spots = Spot.find(:all)    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spots }
    end
  end
  
  def show_by_name # here for permanent URL reasons
    redirect_to :action => :show, :id => params[:name]
  end
  
  # GET /spots/1
  # GET /spots/1.xml
  def show
    @spot = Spot.find_by_id params[:id], :include => :quests
    @spot ||= Spot.find_by_name params[:id], :include => :quests

    redirect_to not_found_url and return unless @spot

    params[:focus] = @spot.name

    respond_to do |format|
      format.html # html
      format.xml  { render :xml => @spot }
    end
  end

#  # GET /spots/new
#  # GET /spots/new.xml
#  def new
#  #  @spot = Spot.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @spot }
#    end
#  end

  # GET /spots/1/edit
  def edit
    @spot = Spot.find(params[:id])
    unless @spot.is_editable_by? current_user
      flash[:notice] = "Sry, not allowed!"
      redirect_to root_path
    end
  end

  # PUT /spots/1
  # PUT /spots/1.xml
  def update
    @spot = Spot.find(params[:id])

    unless @spot.is_editable_by? current_user
      flash[:notice] = "sry, not allowed!"
      redirect_to root_path
    end

    respond_to do |format|
      if @spot.update_attributes(params[:spot])
        flash[:notice] = 'Spot was successfully updated.'
        format.html { redirect_to(@spot) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @spot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /spots/1
  # DELETE /spots/1.xml
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    respond_to do |format|
      format.html { redirect_to(spot_url) }
      format.xml  { head :ok }
    end
  end
  
  def hotspots
    @spots = Spot.find :all
    @spots = @spots.sort {|s, ss| s.claims.count <=> ss.claims.count }.reverse[0...10]
  end
end
