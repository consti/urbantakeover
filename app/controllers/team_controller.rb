class TeamController < ApplicationController
  def show
    @team = Team.find params[:id]
  end
end
