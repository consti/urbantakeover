# Unicode support
$KCODE = 'u'
require 'jcode'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Add additional load paths for your own custom dirs
  config.load_paths += Dir[File.join(RAILS_ROOT, 'vendor', 'gems','*', 'lib')]

  # Turn off the annoying coloring in the logs
  config.active_record.colorize_logging = false
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options  
  config.after_initialize do # according to http://beast.caboo.se/forums/2/topics/808
    WhiteListHelper.tags.merge %w(table td tr th u s embed object q param)
    WhiteListHelper.bad_tags.merge %w(iframe)
    WhiteListHelper.attributes.merge %w(autostart autoplay data name value flashvars frameborder scrolling marginwidth marginheight)
  end
end

require 'soup_logger'
SOUP_LOGGER.info "-- Starting soup v#{APP_VERSION} in #{RAILS_ENV} environment --"

# Initialize portier
require 'portier'
Portier.works_at 'soup.io','qa.soup.io','local.soup.io:3000'

# Set static host
ActionController::Base.asset_host = "http://#{Portier.address_of(:static)}"
ENV["RAILS_ASSET_ID"] = '' # Disable rails built-in timestamping of assets, it's expensive

# How to change default session options: http://www.railsweenie.com/forums/1/topics/597 
# http://wiki.rubyonrails.org/rails/pages/HowtoChangeSessionOptions
ActionController::Base.session_options[:session_key] = 'soup_session_id'
#ActionController::Base.session_options[:session_domain] = Portier.cookie_domain #comment out for remote login!

# Configure the mailer. Maybe this should go into a yml
config_mailer = YAML.load_file("#{RAILS_ROOT}/config/mail.yml")
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.server_settings = {
  :address => config_mailer['smarthost']['name'],
  :port => config_mailer['smarthost']['port'].to_i,
  # ActionMailer seems to have a bug where it doesn't emit a host name after HELO.
  :domain => "."
}
ActionMailer::Base.server_settings.merge! :authentication => config_mailer['smarthost']['authentication'].to_sym if config_mailer['smarthost']['authentication']
ActionMailer::Base.server_settings.merge! :user_name => config_mailer['smarthost']['user_name'] if config_mailer['smarthost']['user_name']
ActionMailer::Base.server_settings.merge! :password => config_mailer['smarthost']['password'] if config_mailer['smarthost']['password']

if config_mailer['always_to'] && config_mailer['always_to'].length > 0
  Notifier.always_send_to = config_mailer['always_to']
end

# Require gems we are using here
require 'RMagick'
require 'rfeedparser' # local version

require 'acts_as_ferret'


# This must be required before anything that uses caching (including observers) 
# to avoid auto-loading it on every request in development environment!
# Configure application cache, on production use memcache, in devel use memory store
if $DO_NOT_CACHE_AC_FRAGMENTS
  puts "Running uncached."
elsif RAILS_ENV == 'production'
  ActionController::Base.fragment_cache_store = :mem_cache_store, MemcacheInstances.server(:application), MemcacheInstances::DEFAULT_MEMCACHE_OPTIONS
else
  ActionController::Base.fragment_cache_store = :memory_store
end
require 'caching'

# Require our custom extensions (lib/support.rb)
require 'support'
require 'patches'

require File.join(File.dirname(__FILE__), 'environment-fidel_client')

# Explicitely require, otherwise the class is reloaded on each req in devel mode and 
# config values are reset.
require "#{RAILS_ROOT}/lib/fidel_server"
config_fidel = YAML.load_file(File.join(File.dirname(__FILE__), 'fidel.yml'))
FidelServer::THREADS[:bg][:n] = config_fidel['threads']['bg']
FidelServer::THREADS[:fg][:n] = config_fidel['threads']['fg']


# Load all models right now  to stop delays on first request and possibly needed by caching.rb
# This is also important for the ferret:rebuild because it expects models to be defined after the environment
# is initialized
#if RAILS_ENV == 'production' # This is needed in development mode as well (see above note on ferret:rebuild)
  Dir.glob("#{RAILS_ROOT}/app/models/*.rb").each do |m|
    require_dependency File.basename(m,'.rb')
  end
  require_dependency 'feed/base'
#end

# Activate observers 
# autoload (needed for console, the next line doesn't activate it there?)
PostObserver.instance 
UserObserver.instance 

ActiveRecord::Base.observers = :post_observer, :user_observer 
