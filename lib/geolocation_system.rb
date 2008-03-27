module GeolocationSystem
  protected
    def current_city
      if logged_in?
        current_user.city
      else
        City.find_by_name 'Wien' #TODO: find by ip address in session
      end
    end
    
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_city
    end
end
