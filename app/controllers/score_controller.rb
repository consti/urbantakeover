class ScoreController < ApplicationController
  before_filter :login_required, :except => [:index, :all]

  def index
    redirect_to :controller => :claims, :action => :all
  end
    
  def dismiss
    current_user.scores_seen_until = Time.now
    current_user.save!
    redirect_back_or_default root_url
  end
end
