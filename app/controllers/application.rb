# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include GeolocationSystem

  before_filter :login_from_cookie
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'd865e93d462697055b1bdba47fcabd7f'
  
  
  protected
  
    def log_error(exception) 
      super(exception)

      begin
        ErrorMailer.deliver_snapshot(
          exception, 
          clean_backtrace(exception), 
          @session.instance_variable_get("@data"), 
          @params, 
          @request.env)
      rescue => e
        logger.error(e)
      end
    end
end
