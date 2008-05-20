class CityController < ApplicationController
  before_filter :login_required, :only => [:edit, :new]

  def authorized?
    current_user.is_admin?
  end

  def new
    @city = City.new params[:city]
    return unless request.post?
    @city.save!
    redirect_back_or_default root_url
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
  end

  def edit
    @city = City.find params[:id]
    return unless request.post?

    @city.update_attributes(params[:city])
    @city.save!
    flash[:notice] = 'Changes saved, kbai!'

  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'Changes LASLF'
  end

  def list
    @cities = City.find :all
  end

  def show
    @city = City.find params[:id]
    @city ||= City.find_by_name params[:id]
    
    unless @city
      flash[:notice] = "no such city - #{params[:id]}" 
      redirect_to home_url
      return
    end
  end
end
