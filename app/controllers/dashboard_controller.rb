class DashboardController < ApplicationController
  def newcomer
    load_data

    a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] # Will add descriptions, soon
		@num = a[rand(a.size)]
		render :layout => 'pitch'
  end
  
  def test 
    flickr = Flickr.new RAILS_ROOT + "/config/flickr.cache", PRIVATE_API_CONFIG['flickr']['api_key'], PRIVATE_API_CONFIG['flickr']['shared_secret']
    @photos = flickr.groups.pools.getPhotos("697289@N21", nil, nil, 3)
    
    @photoss = []
    @photos.each do |photo|
      @photoss << flickr.photos.getInfo(photo.id)
      
      [photo.description, photo.title].each do |claim_message|
      end
    end
  end

  def member
    load_data
  end
  
  def redirect
    if logged_in?
      redirect_to :action => :member
    else
      redirect_to :action => :newcomer
    end
  end

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
  
  private
  def load_data
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
end
