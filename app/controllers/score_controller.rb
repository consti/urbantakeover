class ScoreController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    #TODO: faked for now. real' me.
    
    @users = User.find :all
    @users = @users.sort_by(&:score).reverse[0...10]
    
    @teams = Team.find :all
    @teams = @teams.sort_by(&:score).reverse[0...10]
  end
    
  def dismiss
    current_user.scores_seen_until = Time.now
    current_user.save!
    redirect_back_or_default root_url
  end
end
