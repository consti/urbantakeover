class ClaimsController < ApplicationController
  before_filter :login_required
  
  def spot
    spot = Spot.find params[:id]    
    
    if spot.current_owner == current_user
      flash[:notice] = "Already yours :)"
      return redirect_to(:action => 'my')
    end

    Claim.create :user => current_user, :spot => spot

    flash[:notice] = "BAM! Claimed!"
    redirect_to(:action => 'my')
  end
  
  def my
    @claims = current_user.claims.find :all, :order => "created_at desc"
    @owned_spots = current_user.owned_spots
  end
end
