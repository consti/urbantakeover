class GatewayController < ApplicationController
  before_filter :login_required, :only => :website

  def self.private_api values
    before_filter :verify_private_api, :only => values
    skip_before_filter :verify_authenticity_token, :only => values
  end
  
  private_api :twitter

  def twitter
    return render :text => 'already parsed' if Twittermessage.find_by_twitter_id(params[:twitter_message_id])
    
    Twittermessage.create :twitter_id => params[:twitter_message_id]
    
    render :text => handle_message(params[:user], params[:message])
  end
  
  def website
    command = Command.create(:user => current_user, :text => params[:command][:text])
    result = command.run!
    flash[:notice] = result || "sry, something went wrong. no result text??? o_O'"
    return redirect_back_or_default(root_url)
  end

private
  def verify_private_api
    render :text => "gotcha! sorry, but you needs special powarz!" unless params[:key] == PRIVATE_API_KEY
  end

  def handle_message username, message
    message = message.strip.downcase
    #username = username.downcase!

    return "no username" if (username == nil or username.empty?)

    return_message = ""
    user = User.find_by_twittername username
    unless user
      password = "%04d" % (1+rand(9999))
      user = User.create(:twittername => username,
                         :login => username,
                         :password => password,
                         :password_confirmation => password)
      return_message += "Ohay #{username} your password is #{password}! "
      user.save!
      user.reload
    end
    
    command = Command.create(:user => user, :text => message)
    return return_message + command.run!
  end
end
