# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

gem "data_objects", "= 0.2.0"
gem "do_mysql", "<= 0.2.4"
gem "do_sqlite3", "<= 0.2.2"
gem "merb_datamapper", "<= 0.9.2"
gem "datamapper", "<= 0.3.1"


# Make the app's "lib" directory a place where ruby files get "require"d from
$LOAD_PATH.unshift(Merb.root / "lib")


Merb::Config.use do |c|
  
  ### Sets up a custom session id key, if you want to piggyback sessions of other applications
  ### with the cookie session store. If not specified, defaults to '_session_id'.
  # c[:session_id_key] = '_session_id'
  
  c[:session_secret_key]  = 'a140963260bba75cbd912cfbd85fcf4d5187a5db'
end  

### Merb doesn't come with database support by default.  You need
### an ORM plugin.  Install one, and uncomment one of the following lines,
### if you need a database.

### Uncomment for DataMapper ORM
use_orm :datamapper

### Uncomment for ActiveRecord ORM
# use_orm :activerecord

### Uncomment for Sequel ORM
# use_orm :sequel
# 

require "merb-assets"
require "merb-haml"
require "merb_param_protection"
require  "merb-action-args"
require "whistler"
require "redcloth"
require "merb_has_flash"
require "paginator"

dependency "permissions/permissions"
dependency "datamapper_extensions"
dependency "publishable_mixin/model"
dependency "publishable_mixin/controller"
dependency "comment_mixin"
# dependency "publishable_mixin/general_publishable_controller"
dependency "whistler_helpers"
dependency "menu_builder"

### This defines which test framework the generators will use
### rspec is turned on by default
###
### Note that you need to install the merb_rspec if you want to ue
### rspec and merb_test_unit if you want to use test_unit. 
### merb_rspec is installed by default if you did gem install
### merb.
###
# use_test :test_unit
use_test :rspec

### Add your other dependencies here

# These are some examples of how you might specify dependencies.
# 
# dependencies "RedCloth", "merb_helpers"
# OR
# dependency "RedCloth", "> 3.0"
# OR
# dependencies "RedCloth" => "> 3.0", "ruby-aes-cext" => "= 1.0"

Language::English::Inflect.word "news", "news"

Merb::BootLoader.after_app_loads do
  Merb.add_mime_type(:atom,  :to_atom,  %w[application/atom+xml], :Encoding => "UTF-8")
  ### Add dependencies here that must load after the application loads:

  # dependency "magic_admin" # this gem uses the app's model classes
  # Keep alive for the databse
  if Merb.env?(:production)
   $tickler = Thread.new do
     loop do
       DataMapper.database.query("SELECT * FROM people LIMIT 1")
       Merb.logger.info "Tickled Database at #{Time.new}"
       Merb.logger.info.flush
       sleep(5*60)
     end
   end
   $tickler.priority = -10
  end
    
  
  
end

begin 
  require File.join(File.dirname(__FILE__), '..', 'lib', 'authenticated_system/authenticated_dependencies') 
rescue LoadError
end
