class ScoreController < ApplicationController
  before_filter :login_required

  def index
    @user = current_user
  end
  
  def dismiss
    current_user.scores_seen_until = Time.now
    current_user.save
    redirect_to root_url
  end
end
