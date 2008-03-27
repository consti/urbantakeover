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
    unless user
      password = "%04d" % (1+rand(9999))
      user = User.create(:twittername => username,
                         :login => username,
                         :password => password,
                         :password_confirmation => password)

      unless user.save
        user.send_notify "failed to create user #{username}! contact team@72dpiarmy.com plz!"
        err = user.errors.full_messages.join(", ")
        return render :text => "wtf? fail create user: #{err}"
      end
      
      user.send_notify "ohai #{username}! your password for http://urbantakeover.at is #{password}. enjoy! send 'claim spot' to play!"

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
