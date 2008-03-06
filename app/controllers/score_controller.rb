class ScoreController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    #TODO: faked for now. real' me.
    
    @users = User.find :all
    @users = @users.sort_by(&:total_score).reverse
  end
  
  def my
    @user = current_user
  end
  
  def dismiss
    current_user.scores_seen_until = Time.now
    current_user.save
    redirect_back_or_default root_url
  end
end
