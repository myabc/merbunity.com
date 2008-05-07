require 'rubygems'
Gem.clear_paths
Gem.path.unshift(File.join(File.dirname(__FILE__), "gems"))

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'
require 'merb-core'
require 'rubigen'
include FileUtils



init_env = ENV['MERB_ENV'] || 'development'
log_file = Merb.log_path / 'rake.log' 

Merb.load_dependencies(:environment => init_env)    

require 'merb_activerecord'

# # # Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each {|r| require r } 

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
      p.password = "password"
      p.password_confirmation = "password"
      p.save
      p.activate
      puts "Created person"
          
      p = Person.new(valid_person_hash)
      p.login = "publisher"
      p.password = "password"
      p.password_confirmation = "password"
      p.save
      p.activate
      p.make_publisher!
      puts "Created publisher"
          
      p = Person.new(valid_person_hash)
      p.login = "admin"
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