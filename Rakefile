require 'rubygems'
Gem.clear_paths
Gem.path.unshift(File.join(File.dirname(__FILE__), "gems"))

require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'

require File.dirname(__FILE__)+'/config/boot.rb'
require Merb::framework_root+'/tasks'
include FileUtils

# Set these before any dependencies load
# otherwise the ORM may connect to the wrong env
Merb.root = File.dirname(__FILE__)
Merb.environment = ENV['MERB_ENV'] if ENV['MERB_ENV']

# Get Merb plugins and dependencies
require File.dirname(__FILE__)+'/config/dependencies.rb'
Merb::Plugins.rakefiles.each {|r| require r } 

#desc "Packages up Merb."
#task :default => [:package]

desc "load merb_init.rb"
task :merb_init do
  # deprecated - here for BC
  Rake::Task['merb_env'].invoke
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

desc 'Run unit tests'
Rake::TestTask.new('test_unit') do |t|
  t.libs << 'test'
  t.pattern = 'test/unit/*_test.rb'
  t.verbose = true
end

desc 'Run functional tests'
Rake::TestTask.new('test_functional') do |t|
  t.libs << 'test'
  t.pattern = 'test/functional/*_test.rb'
  t.verbose = true
end

desc 'Run all tests'
Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
end

desc "Run all model specs"
Spec::Rake::SpecTask.new('model_specs') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir['spec/models/**/*_spec.rb'].sort
end

desc "Run all controller specs"
Spec::Rake::SpecTask.new('controller_specs') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir['spec/controllers/**/*_spec.rb'].sort
end

desc "Run a specific spec with TASK=xxxx"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.libs = ['lib', 'server/lib' ]
  t.spec_files = ["spec/merb/#{ENV['TASK']}_spec.rb"]
end

desc "Run all specs output html"
Spec::Rake::SpecTask.new('specs_html') do |t|
  t.spec_opts = ["--format", "html"]
  t.libs = ['lib', 'server/lib' ]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
end

desc "RCov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir['spec/**/*_spec.rb'].sort
  t.libs = ['lib', 'server/lib' ]
  t.rcov = true
end

desc 'Run all tests, specs and finish with rcov'
task :aok do
  sh %{rake rcov}
  sh %{rake spec}
end

# namespace :story do
#   desc "Run the given story"
#   task :run, :story_name do |t,args|
#     sh %{ruby stories/stories/#{args.story_name}.rb}
#   end
#   
#   desc "Run all stories"
#   task :all do
#     story_path = "stories/stories"
#     # all_stories = Dir.glob(story_path + "/**/*.rb").inject([]){|as,s| as << s.split("/").last[0..-4]}
#     all_stories = Dir.glob(story_path + "/**/*.rb")
#     # all_stories.each{ |story| sh %{ruby stories/stories/#{story}.rb} }
#     all_stories.each{ |story| sh %{ruby #{story}}}
#   end
# end


unless Gem.cache.search("haml").empty?
  namespace :haml do
    desc "Compiles all sass files into CSS"
    task :compile_sass do
      gem 'haml'
      require 'sass'
      puts "*** Updating stylesheets"
      Sass::Plugin.update_stylesheets
      puts "*** Done"      
    end
  end
end

##############################################################################
# SVN
##############################################################################

desc "Add new files to subversion"
task :svn_add do
   system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
end

rule "" do |t|
  spec_cmd = (RUBY_PLATFORM =~ /java/) ? "jruby -S spec" : "spec"
  # spec:spec_file:spec_name
  if /spec:(.*)$/.match(t.name)
    arguments = t.name.split(':')
    
    file_name = arguments[1]
    spec_name = arguments[2..-1]

    spec_filename = "#{file_name}_spec.rb"
    specs = Dir["spec/**/#{spec_filename}"]
    
    puts "number of specs found #{spec_filename}"
    
    if path = specs.detect { |f| spec_filename == File.basename(f) }
      run_file_name = path
    else
      puts "No specs found for #{t.name.inspect}"
      exit
    end

    example = " -e '#{spec_name}'" unless spec_name.empty?
    
    sh "#{spec_cmd} #{run_file_name} --format specdoc --colour #{example}"
  end
end
