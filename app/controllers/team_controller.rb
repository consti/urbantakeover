class TeamController < ApplicationController
  def show
    @team = Team.find params[:id]
    @team ||= Team.find_by_name params[:id]
  end
  
  def show_by_name
    @team = Team.find_by_name params[:name]
    render :template => 'team/show'
  end
  
  def index
  end
end
