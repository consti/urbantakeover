class SpotsController < ApplicationController
  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]

  def authorized?
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
  
  # GET /spots/1
  # GET /spots/1.xml
  def show
    @spot = Spot.find(params[:id])
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
  end

#  # POST /spots
#  # POST /spots.xml
#  def create
#    @spot = Spot.new(params[:spot])
#
#    respond_to do |format|
#      if @spot.save
#        flash[:notice] = 'Spot was successfully created.'
#        format.html { redirect_to(@spot) }
#        format.xml  { render :xml => @spot, :status => :created, :location => @spot }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @spot.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # PUT /spots/1
  # PUT /spots/1.xml
  def update
    @spot = Spot.find(params[:id])

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
      format.html { redirect_to(spots_url) }
      format.xml  { head :ok }
    end
  end
end
