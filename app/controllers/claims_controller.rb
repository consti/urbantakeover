class ClaimsController < ApplicationController
  before_filter :login_required, :except => [:log, :howto, :faq, :all]

  def my
    redirect_to :controller => :user, :action => :show, :id => current_user
  end
  
  def log
    @claims = Claim.find :all, :order => "created_at desc"
  end
  
  def all
    @claims = Claim.find :all
    @spots = Spot.find :all #todo: something like :conditions => "claim_id != null"
    
    #TODO: faked for now. real' me.
    @users = User.find :all
    @users = @users.sort_by(&:score).reverse[0...10]
    
    @teams = Team.find :all
    @teams = @teams.sort_by(&:score).reverse[0...10]
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
end