# The friendly link'er is used to give people helpful links when they go to http://uto.io/something
# name refactorization welcome ;)

class DisambiguationController < ApplicationController
  @@models = [User, Spot, Team, City]
  
  def index
    name = params[:name]
    objects = find_ambiguate_by name
    
    if objects.length == 1
      object = objects.first
      return redirect_to(:controller => object.class.name.downcase, :action => :show, :id => object)
    else
      redirect_to :action => :disambiguate, :name => name
    end
  end

  def disambiguate
    @objects = find_ambiguate_by params[:name]
    redirect_to not_found_url and return if @objects.empty?
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
