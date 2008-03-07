class ClaimsController < ApplicationController
  before_filter :login_required, :except => :log
  
  def my
    @claims = current_user.claims
    @owned_spots = current_user.owned_spots
  end
  
  def log
    @claims = Claim.find :all, :order => "created_at desc"
  end
  
  def new
    @command = Command.new(params[:command])
  end
end