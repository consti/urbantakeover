# The friendly link'er is used to give people helpful links when they go to http://uto.io/something
# name refactorization welcome ;)

class FriendlynkerController < ApplicationController

  def index
    name = params[:name]
    user = User.find_by_login name
    spot = Spot.find_by_name name
    
    # TODO: all temporary redirect code, here be no permalinks!
    if user and spot
      redirect_to(:action => :disambiguate, :name => name)
    elsif user
      redirect_to(:controller => :user, :action => :show_by_name, :name => name)
    elsif spot
      redirect_to(:controller => :spots, :action => :show_by_name, :name => name)
    else
      # TODO: redirect to 404 page and send proper error response @hacketyhack
      flash[:notice] = "sorry, nothing found"
      redirect_to root_url
    end
  end

  def disambiguate
    @name = params[:name]
    @user = User.find_by_login @name
    @spot = Spot.find_by_name @name
  end
end
