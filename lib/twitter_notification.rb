module TwitterNotification
  def twitter_send username, message
    @twitter ||= load_twitter
    @twitter.d(username, message)
  end
  
  def configuration
    Twitter::Base.new(PRIVATE_API_CONFIG['twitter']['email'], PRIVATE_API_CONFIG['twitter']['password'])
  end
end
