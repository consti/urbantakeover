class TeamController < ApplicationController
  def show
    @team = Team.find params[:id]
    @team ||= Team.find_by_name params[:id]
  end
  
  def show_by_name
    @team = Team.find_by_name params[:name]
    
    unless @team
      flash[:notice] = "no team #{params[:name]} found, sry"
      redirect_back_or_default home_path
    end
    
    render :template => 'team/show'
  end
  
  def index
  end
end
