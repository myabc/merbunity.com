# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb' 
 
use_orm :datamapper
use_test :rspec
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '2773970b4f90323a09566f8fb4dfb9e03f18348a'  # required for cookie session store
  c[:session_id_key] = '_merbunity-site_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
  Merb.push_path(:dm_extensions, Merb.root / "lib", "dm/**/*.rb")
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end
