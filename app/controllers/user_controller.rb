class UserController < ApplicationController
  # say something nice, you goof!  something sweet.
  def index
    redirect_to root_url
  end
  
  def edit
    @user = User.find(params[:id])
    
    #authorize
    if not logged_in? or (current_user != @user and not current_user.is_admin?)
      flash[:notice] = "surely not!"
      redirect_to root_url
    end
    
    if request.post?
      @user.update_attributes(params[:user])
      @user.save
      current_user.reload
    end

  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'Speichern haut net hin!'
    render :action => 'edit'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default(:controller => '/user', :action => 'index')
    else
      flash[:notice] = "Password? LAWL!!!"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default root_url
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/user', :action => 'index')
  end
  
  
end
