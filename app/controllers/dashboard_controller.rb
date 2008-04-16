class DashboardController < ApplicationController

  def admin
    @sparklines = {}
    
    days_count = 7*8
    
    now = Time.new
    check_day = now - days_count.days

    what = ['user', 'claim', 'team', 'spot', 'command', 'score']
    what.each { |w| @sparklines[w] = [] }
    while check_day <= now
      what.each do |w|
        count = w.classify.constantize.count(:conditions => ["created_at >= ? and created_at < ?", check_day, check_day+1.days])
        @sparklines[w] << count
      end
      check_day += 1.days
    end
  end
end
