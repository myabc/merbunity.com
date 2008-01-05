MERB_ENV="test"
$TESTING=true
require File.join(File.dirname(__FILE__), "..", 'config', 'boot')
require File.join(MERB_ROOT, 'config', 'merb_init')

require 'merb/test/helper'
require 'merb/test/rspec'

Spec::Runner.configure do |config|
    config.include(Merb::Test::Helper)
    config.include(Merb::Test::RspecMatchers)
end


### METHODS BELOW THIS LINE SHOULD BE EXTRACTED TO MERB ITSELF
