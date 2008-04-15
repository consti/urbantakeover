# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include GeolocationSystem
  include ExceptionNotifiable

  before_filter :login_from_cookie
  before_filter :flashify_new_scores
  
  def flashify_new_scores
    return unless logged_in?
    scores = current_user.scores.find :all, :conditions => ["created_at > ?", current_user.scores_seen_until]
    current_user.scores_seen_until = Time.now
    current_user.save
    
    @scores = []    
    scores.each do |score|
      @scores << if score.points > 0
        "#{score.description}, get #{score.points} points!"
      elsif score.points < 0
        "#{score.description}, loose #{score.points.abs} points!"
      else
        score.description
      end
    end
  end

  helper :all # include all helpers, all the time
  
  helper_method :app_path
  def app_path
    "/files/Urban Takeover.zip"
  end
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd865e93d462697055b1bdba47fcabd7f'
end
