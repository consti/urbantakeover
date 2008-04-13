# The friendly link'er is used to give people helpful links when they go to http://uto.io/something
# name refactorization welcome ;)

class DisambiguationController < ApplicationController
  @@models = [User, Spot, Team]
  
  def index
    name = params[:name]
    objects = find_ambiguate_by name
    
    if objects.length == 1
      object = objects.first
      return redirect_to(:controller => object.class.name.downcase, :action => :show_by_name, :name => object.name)
    else
      redirect_to :action => :disambiguate, :name => name
    end
  end

  def disambiguate
    @objects = find_ambiguate_by params[:name]
    redirect_to "/404.html" if @objects.empty?
  end
  
  private
  def find_ambiguate_by name
    objects = []
    @@models.each do |model|
      objects += model.find_all_by_name(name)
    end
    objects
  end
end
