# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")


require 'dm-core'
require 'do_sqlite3' if Merb.env?(:development)
load 'merb-core/vendor/facets/inflect.rb' # Required because extlib requires gem version of english inflector which overwrites the vendored one



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
# 
dependency "merb-slices"
dependency "merb-auth"

require "merb-assets"
require "merb-haml"
require "merb-mailer"
require "merb_param_protection"
require "merb-action-args"
require "whistler"
require "redcloth"
require "merb_has_flash"
require "paginator"
require 'dm-validations'
require 'dm-timestamps'
require 'dm-aggregates'




dependency "whistler_helpers"
dependency "menu_builder"
dependency "permissions/permissions"
dependency "publishable_mixin/model"
dependency "publishable_mixin/controller"
dependency "datamapper_extensions"

dependency "merbunity-bot/lib/broadcaster"


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

Merb::BootLoader.before_app_loads do
  MA[:layout] = :application
  MA[:forgotten_password] = true
  MA[:use_activation] = true unless Merb.env?(:development)
  DataObjects::Sqlite3.logger = DataMapper::Logger.new(STDOUT, :debug) if Merb.env?(:development)
  
  send_to = Merb.env?(:production) ? "notifications@merbunity.com" : "dev-notifications@merbunity.com"
  Merb.logger.info "mongrel@merbunity.com/pid#{$$}"
  puts "SET TO SEND TO #{send_to}"
  Broadcaster.setup("mongrel@merbunity.com/pid#{$$}", "8Q4113", send_to)
end

Merb::BootLoader.after_app_loads do
  
  Merb.add_mime_type(:atom,  :to_atom,  %w[application/atom+xml], :Encoding => "UTF-8")
  ### Add dependencies here that must load after the application loads:
end
