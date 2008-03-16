class ClaimsController < ApplicationController
  before_filter :login_required, :except => [:log, :howto, :recent]
  
  def my
    @claims = current_user.claims
    @owned_spots = current_user.owned_spots
  end
  
  def log
    @claims = Claim.find :all, :order => "created_at desc"
  end
  
  def new
    @command = Command.new(params[:command])
    
    return unless request.post?
    command = Command.create(:user => current_user, :text => params[:command][:text])
    result = command.run!
    flash[:notice] = result || "sry, something went wrong. no result text??? o_O'"
    
    #todo output command if successfull
  end
  
  def howto
  end
  
  # GET /recent
  # GET /recent.xml
  def recent
    @recent_claims = Claim.find :all, :limit => 16, :order => "created_at desc"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recent_claims }
    end

  end
end