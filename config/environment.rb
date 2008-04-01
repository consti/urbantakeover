# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require "twitter"
require "from_future_import"

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_urbantakeover_session',
    :secret      => '3744a02be16fccf8f780dbd0a142ef15f94e4b4c40f1ecd4732de83d9b7ef1e856bfb469f2785012282a7232c62231de4b5b7c82b520e21464ad07590d5f387b'
  }
  
  PRIVATE_API_CONFIG = YAML.load(File.open("#{RAILS_ROOT}/config/private_api.yml"))
  PRIVATE_API_KEY = PRIVATE_API_CONFIG['api_key']
  
  TWITTER = Twitter::Base.new(PRIVATE_API_CONFIG['twitter']['email'], PRIVATE_API_CONFIG['twitter']['password'])

  # thanx http://www.wanlord.com/articles/2007/11/29/sending-email-using-actionmailer-and-gmail
  require 'tlsmail'
  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
  config.action_mailer.delivery_method = :smtp
  
  config.action_mailer.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => PRIVATE_API_CONFIG['gmail']['domain'],
    :authentication => :plain,
    :user_name => "%s@%s" % [ PRIVATE_API_CONFIG['gmail']['user'], PRIVATE_API_CONFIG['gmail']['domain'] ],
    :password => PRIVATE_API_CONFIG['gmail']['password'],
  }
  
  config.action_mailer.raise_delivery_errors = true

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

ExceptionNotifier.exception_recipients = %w(team@72dpiarmy.com) 
ExceptionNotifier.sender_address = %("UTO Bug" <team@72dpiarmy.com>)
