require 'rubygems'
require 'spec/rake/spectask'
require File.join(File.dirname(__FILE__), "..", "spec", "spec_helper")
require 'spec/mocks'
require 'spec/story'

require 'merb_stories'

class MerbStory
  include PersonSpecHelper 
  include ValidHashHelpers
end

DataMapper::Base.auto_migrate!

Dir['stories/steps/**/*.rb'].each do |steps_file|
  require steps_file
end

