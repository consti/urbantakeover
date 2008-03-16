set :application, "urbantakeover"
set :repository,  "https://svn.72dpiarmy.beanstalkapp.com/urbantakeover/trunk"
set :svn_username, "glados"
set :svn_password, "8fce263fa00c887b280336f9e5913c80f4007e64"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "urbantakeover.at"
role :web, "urbantakeover.at"
role :db,  "urbantakeover.at", :primary => true

set :deploy_to, "/home/oneup/urbantakeover"
