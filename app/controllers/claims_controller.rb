class ClaimsController < ApplicationController
  before_filter :login_required
  
  def spot
    spot = Spot.find params[:id]    
    
    #return unless request.post? # TODO: require sticker code
    
    unless current_user.can_claim? spot
      flash[:notice] = "Already yours ;)"
      return redirect_back_or_default root_url
    end

    current_user.claim spot

    flash[:notice] = "BAM! Claimed!"
    redirect_to(root_url(:focus => spot.code))
  end
  
  def my
    @claims = current_user.claims.find :all, :order => "created_at desc"
    @owned_spots = current_user.owned_spots
  end
end
