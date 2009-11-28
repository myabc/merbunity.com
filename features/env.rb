# Sets up the Merb environment for Cucumber (thanks to krzys and roman)
require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec"
require "merb_cucumber/world/webrat"
require "merb_cucumber/helpers/datamapper"

# Uncomment if you want transactional fixtures
# Merb::Test::World::Base.use_transactional_fixtures

require File.join(File.dirname(__FILE__), "../spec/spec_helper")
