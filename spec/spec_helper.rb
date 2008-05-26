$TESTING=true
require 'rubygems'
require 'merb-core'

Merb.start_environment(:adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

module Merbunity
  module Spec
    module Helpers
    end
  end
end

require File.join( File.dirname(__FILE__), "authenticated_system_spec_helper")
require File.join( File.dirname(__FILE__), "person_spec_helper")
require File.join( File.dirname(__FILE__), "spec_helpers", "valid_hashes")

Dir[File.join( File.dirname(__FILE__), "shared_behaviors", "**", "*.rb")].each do |f|
  require f
end

[Merbunity::Spec::Helpers].each do |h|
  h.send(:include, PersonSpecHelper)
end

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Merbunity::Spec::Helpers)
  
  config.before(:all) do
    Screencast.auto_migrate!
    Person.auto_migrate!
  end
  config.after(:all) do
    Screencast.all.each{|c| c.destroy!}
  end
end

DataMapper.auto_migrate!

