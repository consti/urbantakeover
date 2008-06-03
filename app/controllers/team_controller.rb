class TeamController < ApplicationController
  before_filter :login_required, :only => [:join, :edit]
  
  def show
    @team = Team.find_by_id params[:id], :include => :users
    @team ||= Team.find_by_name params[:id], :include => :users

    if @team.nil?
      flash[:notice] = "no such team here... YET!" and redirect_to(:action => :create, :name => params[:id])
    end
  end
  
  def edit
    @team = Team.find params[:id]
    unless @team.is_editable_by? current_user
      flash[:notice] = "Sry, not allowed!"
      redirect_to root_path
    end
  end
  
  # PUT /spots/1
  # PUT /spots/1.xml
  def update  
    @team = Team.find params[:id]
    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Yay, saved!'
        format.html { redirect_to(:action => :show, :id => @team) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create
    @team = Team.new(params[:team])  
    return unless request.post?
    @team.save!
    redirect_back_or_default :action => :show, :id => @team
  rescue ActiveRecord::RecordInvalid
    render :action => 'create'
  end


  def join
    team = Team.find params[:id]
    Command.run_for current_user, "team #{team.name}"
    redirect_to show_team_url :name => team.name
  end
  
  def list
    redirect_to :action => :index
  end
  
  def show_by_name # here for permanent URL reasons
    redirect_to :action => :show, :id => params[:name]
  end
end
