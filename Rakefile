require 'rubygems'
Gem.clear_paths
Gem.path.unshift(File.join(File.dirname(__FILE__), "gems"))

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'


##
# requires frozen merb-core (from /framework)
# adds the other components to the load path
def require_frozen_framework
  framework = File.join(File.dirname(__FILE__), "framework")
  if File.directory?(framework)
    puts "Running from frozen framework"
    core = File.join(framework,"merb-core")
    if File.directory?(core)
      puts "using merb-core from #{core}"
      $:.unshift File.join(core,"lib")
      require 'merb-core'
    end
    more = File.join(framework,"merb-more")
    if File.directory?(more)
      Dir.new(more).select {|d| d =~ /merb-/}.each do |d|
        $:.unshift File.join(more,d,'lib')
      end
    end
    plugins = File.join(framework,"merb-plugins")
    if File.directory?(plugins)
      Dir.new(plugins).select {|d| d =~ /merb_/}.each do |d|
        $:.unshift File.join(plugins,d,'lib')
      end
    end
    require "merb-core/core_ext/kernel"
    require "merb-core/core_ext/rubygems"
  else
    p "merb doesn't seem to be frozen in /framework"
    require 'merb-core'
  end
end

if ENV['FROZEN']
  require_frozen_stuff
else
  require 'merb-core'
end

require 'rubigen'
require 'merb-core/tasks/merb'
include FileUtils

init_env = ENV['MERB_ENV'] || 'development'
log_file = Merb.log_path / 'rake.log' 

Merb.load_dependencies(:environment => init_env)    

require 'merb_activerecord'

# # # Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each {|r| require r } 

tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rb"]
rake_files.each{|rake_file| load rake_file }

desc "start runner environment"
task :merb_env do
  Merb.start_environment(:adapter => 'runner', :environment => init_env, :log_file => log_file)
end

namespace :merbunity do
  namespace :db do
    desc "Setup some basic users to get things going for development"
    task :dev_users => :merb_env do
      # require 'spec/spec_helper'
      class Merb::Mailer
        self.delivery_method = :test_send
      end
      require 'spec/spec_helpers/valid_hashes'
      # require 'spec/authenticated_system_spec_helper'
      require 'spec/person_spec_helper'  
      include PersonSpecHelper  
      # DataMapper::Base.auto_migrate!
      
      p = Person.new(valid_person_hash)
      p.login = "person"
      p.email = "person@merbunity.com"
      p.password = "password"
      p.password_confirmation = "password"
      p.save
      p.activate
      puts "Created person"
          
      p = Person.new(valid_person_hash)
      p.login = "publisher"
      p.email = "publisher@merbunity.com"
      p.password = "password"
      p.password_confirmation = "password"
      p.save
      p.activate
      p.make_publisher!
      puts "Created publisher"
          
      p = Person.new(valid_person_hash)
      p.login = "admin"
      p.email = "admin@merbunity.com"
      p.password = "password"
      p.password_confirmation = "password"
      p.save
      p.activate
      p.make_admin!    
      puts "Created admin"
    end
  
    desc "Wipe the db's"
    task :reset => :merb_env do
      DataMapper::Base.auto_migrate!
    end
  end
end
