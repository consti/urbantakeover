class TwitterController < ApplicationController
  before_filter :login_required, :only => :website

  def self.private_api values
    before_filter :verify_private_api, :only => values
    skip_before_filter :verify_authenticity_token, :only => values
  end
  
  private_api [:command, :auto_follow]

  def command  
    return render :text => 'already parsed' if Twittermessage.find_by_twitter_id(params[:twitter_message_id])
    
    Twittermessage.create :twitter_id => params[:twitter_message_id]
    
    render :text => handle_message(params[:user], params[:message])
  end
  
  def auto_follow
    username = params[:user]
    user = User.find_by_twittername username
    login = username
    unless user
      login = (username + rand(128).to_s) if User.find_by_login login # todo fix me properly
      
      password = User.generate_password
      user = User.create(:twittername => username,
                         :login => login,
                         :password => password,
                         :password_confirmation => password)
<<<<<<< HEAD:app/controllers/twitter_controller.rb
=======

>>>>>>> c369d5d45917c7552d38f7285836f0e5abd2a0bc:app/controllers/twitter_controller.rb
      user.notify_all "welcome #{username}! your password for http://urbantakeover.at is #{password}. send 'd cpu claim spot @ address' or 'd cpu help'."
      return render :text => "created user #{username} and following on twitter"
    end
    
    return render :text => "already here: user #{username}"
  end

private
  def verify_private_api
    render :text => "gotcha! sorry, but you needs special powarz!" unless params[:key] == PRIVATE_API_KEY
  end

  def handle_message username, message
    username = username.downcase
    message = message.strip.downcase
    
    user = User.find_by_twittername username
    return "fuck, no user found for #{username}" unless user
    
    command = Command.create(:user => user, :text => message, :source => 'twitter')
    return command.run!
  end
end