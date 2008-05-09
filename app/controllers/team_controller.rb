class TeamController < ApplicationController
  def show
    @team = Team.find params[:id]
    @team ||= Team.find_by_name params[:id]
  end
  
  def join
    team = Team.find params[:id]
    # tODO. login required
    Command.run_for current_user, "team #{team.name}"
    redirect_to show_team_url :name => team.name
  end
  
  def show_by_name
    @team = Team.find_by_name params[:name]
    
    unless @team
      flash[:notice] = "no team #{params[:name]} found, sry"
      return redirect_back_or_default root_path
    end
    
    render :template => 'team/show'
  end
  
  def index
  end
end
