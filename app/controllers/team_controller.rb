class TeamController < ApplicationController
  def show
    @team = Team.find params[:id]
  end
  
  def show_by_name
    @user = Team.find_by_name params[:name]
    render :template => 'team/show'
  end
end
