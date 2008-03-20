module GeolocationSystem
  protected
    def current_city
      if logged_in?
        return current_user.city
      else
        #TODO: find by ip address in session
        return City.find_by_name 'Wien'
      end
    end
    
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_city
    end
end
