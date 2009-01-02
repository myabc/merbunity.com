require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks


Merb::BootLoader.before_app_loads do
  require 'machinist'
  require 'machinist/adapters/datamapper'
end

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

require File.join(File.dirname(__FILE__), "blueprints", "blueprints")
Dir[File.join(File.dirname(__FILE__), "shared_specs", "**/*.rb")].each{ |f| require f }

module CustomMatchers

  class BeUnauthenticated
    def matches?(target)
      @target = target
      @target.status == 401
    end
    def failure_message
      "expected #{@target.url} to be unauthenticated (401) but was #{@target.status}"
    end
    def negative_failure_message
      "expected #{@target.url} to be authenticated but was unauthenticated (401)"
    end
  end
  
  def require_authentication
    BeUnauthenticated.new
  end
end

module LoginHelper
  def login(login = nil, password = nil)
    u = User.make(:login => "fred", :password => "sekrit", :password_confirmation => "sekrit") if !login
    login     ||= "fred"
    password  ||= "sekrit"
    request(url(:login), :method => "PUT", :params => {:login => login, :password => password})
  end
end

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(LoginHelper)
  config.include(CustomMatchers)
  config.before(:each) { Sham.reset }
end

DataMapper.auto_migrate!