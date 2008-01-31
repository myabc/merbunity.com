$TESTING=true
require File.join(File.dirname(__FILE__), "..", 'config', 'boot')
Merb.environment="test"
require File.join(Merb.root, 'config', 'merb_init')

requires 'merb/test/helper'
requires 'merb/test/rspec'
requires (File.dirname(__FILE__) / 'valid_hash_helper')
requires (File.dirname(__FILE__) / 'person_spec_helper')
require (File.dirname(__FILE__) / 'authenticated_system_spec_helper')
require (File.dirname(__FILE__) / 'core_ext_spec_helper')

Spec::Runner.configure do |config|
    config.include(Merb::Test::Helper)
    config.include(Merb::Test::RspecMatchers)
    # config.include(Merb::Test::Multipart::TestHelper)
    config.include(ValidHashHelpers)
    config.include(PersonSpecHelper)
    config.before(:all) do
      Cast.auto_migrate!
      Person.auto_migrate!
    end
    config.after(:all) do
      Cast.all.each{|c| c.destroy!}
    end
end

DataMapper::Base.auto_migrate!

### METHODS BELOW THIS LINE SHOULD BE EXTRACTED TO MERB ITSELF

class Merb::Mailer
  self.delivery_method = :test_send
end