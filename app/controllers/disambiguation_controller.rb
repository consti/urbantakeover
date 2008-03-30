# The friendly link'er is used to give people helpful links when they go to http://uto.io/something
# name refactorization welcome ;)

class DisambiguationController < ApplicationController
  @@models = [User, Spot, Team]
  
  def index
    name = params[:name]
    objects = []
    @@models.each do |model|
      objects += model.find_all_by_name(params[:name])
    end

    if objects.length == 1
      object = objects.first
      return redirect_to(:controller => object.class.name.downcase, :action => :show_by_name, :name => name)
    else
      session[:ambiguate_objects] = objects
      redirect_to :action => :disambiguate
    end
  end

  def disambiguate
    @objects = session[:ambiguate_objects]
  end
end
