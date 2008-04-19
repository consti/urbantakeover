class ScoreController < ApplicationController
  def index
    redirect_to :controller => :claims, :action => :all
  end
end
