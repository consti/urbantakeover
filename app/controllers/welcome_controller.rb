class WelcomeController < ApplicationController
  #before_filter :login_required, :except => [:check, :index]

  def newcomer
    @recent_claims = Claim.find :all, :limit => 10, :order => "created_at desc"
    @last_claim = Claim.find :all, :limit => 1, :order => "created_at desc"
    now = DateTime::now()
    in24h = DateTime.new(now.year,now.month,now.mday+1) # might be very buggy.. I mean, 32 days?
    aweekago = DateTime.new(now.year,now.month,now.mday-7) # might be very buggy.. I mean, -6 days?
    today = now.strftime("%Y")+"-"+now.strftime("%m")+"-"+now.strftime("%d")
    tomorrow = in24h.strftime("%Y")+"-"+in24h.strftime("%m")+"-"+in24h.strftime("%d")
    lastweek = aweekago.strftime("%Y")+"-"+aweekago.strftime("%m")+"-"+aweekago.strftime("%d")
    @claims_today = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE created_at >= '#{today}' and created_at < '#{tomorrow}'"    
    claims_aweekago = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE created_at >= '#{lastweek}' and created_at <= '#{today}'"
    updates_aweekago = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE updated_at >= '#{lastweek}' and updated_at <= '#{today}'"
    @crosses_week = updates_aweekago - claims_aweekago
    @num_claims = Claim.count_by_sql "SELECT COUNT(*) FROM claims"    
    a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # Will add descriptions, soon
		@num = a[rand(a.size)]
  end

  def member
     @recent_claims = Claim.find :all, :limit => 10, :order => "created_at desc"
     @last_claim = Claim.find :all, :limit => 1, :order => "created_at desc"
     now = DateTime::now()
     in24h = DateTime.new(now.year,now.month,now.mday+1) # might be very buggy.. I mean, 32 days?
     aweekago = DateTime.new(now.year,now.month,now.mday-7) # might be very buggy.. I mean, -6 days?
     today = now.strftime("%Y")+"-"+now.strftime("%m")+"-"+now.strftime("%d")
     tomorrow = in24h.strftime("%Y")+"-"+in24h.strftime("%m")+"-"+in24h.strftime("%d")
     lastweek = aweekago.strftime("%Y")+"-"+aweekago.strftime("%m")+"-"+aweekago.strftime("%d")
     @claims_today = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE created_at >= '#{today}' and created_at < '#{tomorrow}'"    
     claims_aweekago = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE created_at >= '#{lastweek}' and created_at <= '#{today}'"
     updates_aweekago = Claim.count_by_sql "SELECT COUNT(*) FROM claims WHERE updated_at >= '#{lastweek}' and updated_at <= '#{today}'"
     @crosses_week = updates_aweekago - claims_aweekago
     @num_claims = Claim.count_by_sql "SELECT COUNT(*) FROM claims"    
  end
  
  def check
      if !logged_in?
         redirect_to :controller => :welcome, :action => :newcomer
      else
         redirect_to :controller => :welcome, :action => :member
      end
  end

end
