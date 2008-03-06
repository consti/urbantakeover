class ScoreController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    #TODO: faked for now. real' me.
    
    @users = User.find :all
    @users.sort {|u, u1| u.total_score <=> u1.total_score }
  end
  
  def my
    @user = current_user
  end
  
  def dismiss
    current_user.scores_seen_until = Time.now
    current_user.save
    redirect_to root_url
  end
end
