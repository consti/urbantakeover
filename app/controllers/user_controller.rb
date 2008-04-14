class UserController < ApplicationController
  before_filter :login_required, :only => [:add_friend, :remove_friend, :edit, :profile, :settings]
  
  # TODO: refactor me! get rid of settings/profile distinction
  def settings
    redirect_to :action => 'edit', :id => current_user.id
  end
  
  def home
    # home_path should be used instead of root_path once we have the pitch frontpage & dashboard frontpage ready
    unless flash[:notice]
      flash[:notice] = "Welcome home #{current_user.name} :)" if logged_in?
    end
    

    redirect_to root_path # redirect to root, because we have no dashboard yet
  end
  
  def index
    home
  end
  
  def forgot_password
    return unless request.post?

    user = User.find_by_name params[:name]

    new_password = User.generate_password
    user.password = new_password
    user.password_confirmation = user.password

    user.save!
    user.notify_all "Your new password is #{new_password}."
  end
    
  
  def show_by_name
    @user = User.find_by_login params[:name]
    return redirect_back_or_default(root_url) unless @user
    show
    render :template => 'user/show'
  end

  def show
    @user ||= User.find(params[:id])
    @claims = @user.claims
  end
  
  def add_friend
    friend = User.find(params[:id])
    
    Command.run_for current_user, "friend #{friend.name}", "web"
    
    redirect_back_or_default :controller => 'user', :action => 'show_by_name', :name => friend.name
  end
  
  def remove_friend
    friend = User.find(params[:id])
    if friend != current_user
      current_user.friends.delete friend
      current_user.save!
    end
    redirect_back_or_default :controller => 'user', :action => 'show_by_name', :name => friend.name
  end
  
  
  def edit
    @user = User.find(params[:id])
    
    #authorize
    if current_user != @user and not current_user.is_admin?
      flash[:notice] = "surely not!"
      redirect_to root_url
    end
    
    if request.post?
      @user.update_attributes(params[:user])
      @user.save
      flash[:notice] = 'Changes saved, kbai!'
      current_user.reload
      
      redirect_to :action => :show, :id => @user
    end

  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'User save failed?!'
    render :action => 'edit'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      self.current_user.remember_me # always remember :)
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      #flash[:notice] = "Logged in successfully"
      redirect_back_or_default home_url
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
    flash[:notice] = "You is teh leave? Kbai! :("
    redirect_back_or_default root_url
  end
  
  def list
    @users = User.find :all
  end
end
