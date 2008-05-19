class TeamController < ApplicationController
  before_filter :login_required, :only => [:join, :edit]
  
  def show
    @team = Team.find params[:id]
    @team ||= Team.find_by_name params[:id]
  end
  
  def join
    team = Team.find params[:id]
    Command.run_for current_user, "team #{team.name}"
    redirect_to show_team_url :name => team.name
  end
  
  def index
  end
  
  def show_by_name # here for permanent URL reasons
    redirect_to :action => :show, :id => params[:name]
  end
end
