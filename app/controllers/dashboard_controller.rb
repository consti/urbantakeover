class DashboardController < ApplicationController

  def urbantakeover
    @sparklines = {
      'test' => [1,2,3,4,5,6,7,6,5,4,3,2,1,0,5,1,2,2,2,2]
    }
    
    days_count = 7*4
    
    now = Time.new
    check_day = now - days_count.days

    user_counts = []
    claim_counts = []
    while check_day <= now
      user_counts << User.count(:conditions => ["created_at >= ? and created_at < ?", check_day, check_day+1.days])
      claim_counts << Claim.count(:conditions => ["created_at >= ? and created_at < ?", check_day, check_day+1.days])
      check_day += 1.days
    end
    
    @sparklines['users'] = user_counts
    @sparklines['claims'] = claim_counts
    
  end
end
