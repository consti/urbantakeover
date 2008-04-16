class ClaimsController < ApplicationController
  before_filter :login_required, :except => [:log, :howto, :faq, :recent]
  
  def my
    @claims = current_user.claims
    @owned_spots = current_user.owned_spots
  end
  
  def log
    @claims = Claim.find :all, :order => "created_at desc"
  end
  
  def new
    @command = Command.new()
    
    return unless request.post?

    # TODO: FIXME
    if params[:target]
      text = "claim #{params[:target]}"
    elsif params[:spot]
      text = "claim #{params[:spot]} @ #{params[:address]}"
    elsif params[:team]
      text = "team #{params[:team]}"
    elsif params[:friend]
      text = "friend #{params[:friend]}"
    else
      text = params[:command]
    end

    command = Command.create(:user => current_user, :text => text, :source => "web")
    result = command.run!
    flash[:notice] = result || "sry, something went wrong. no result text??? o_O'"
    
    #todo output command if successfull
  end
  
  def howto
    redirect_to :action => 'faq' # don't break previous links to this page
  end
  
  def faq
  end
  
  # GET /recent
  # GET /recent.xml
  def recent
    @recent_claims = Claim.find :all, :limit => 16, :order => "created_at desc"
    @recent_spots = @recent_claims.collect{|c| c.spot}.compact

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recent_claims }
    end

  end
end