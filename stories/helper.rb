require 'rubygems'
require 'spec/rake/spectask'
require 'spec/story'
require File.join(File.dirname(__FILE__), "..", "spec", "spec_helper")

class MerbStory
  include Merb::Test::Helper
  include Merb::Test::RspecMatchers
end

# class Spec::Story::GivenScenario
#   def perform(instance, name = nil)
#     DataMapper::Base.auto_migrate!
#     scenario = Spec::Story::Runner::StoryRunner.scenario_from_current_story @name
#     runner = Spec::Story::Runner::ScenarioRunner.new
#     runner.instance_variable_set(:@listeners,[])
#     runner.run(scenario, instance)
#   end
# end

Dir['stories/steps/**/*.rb'].each do |steps_file|
  require steps_file
end

