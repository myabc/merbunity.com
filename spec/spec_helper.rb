$TESTING=true
require File.join(File.dirname(__FILE__), "..", 'config', 'boot')
Merb.environment="test"
require File.join(Merb.root, 'config', 'merb_init')

requires 'merb/test/helper'
requires 'merb/test/rspec'
requires (File.dirname(__FILE__) / 'valid_hash_helper')
requires (File.dirname(__FILE__) / 'author_spec_helper')
require (File.dirname(__FILE__) / 'authenticated_system_spec_helper')

Spec::Runner.configure do |config|
    config.include(Merb::Test::Helper)
    config.include(Merb::Test::RspecMatchers)
    # config.include(Merb::Test::Multipart::TestHelper)
    config.include(ValidHashHelpers)
    config.include(AuthorSpecHelper)
    config.before(:all) do
      Cast.auto_migrate!
      Author.auto_migrate!
    end
end

DataMapper::Base.auto_migrate!

### METHODS BELOW THIS LINE SHOULD BE EXTRACTED TO MERB ITSELF

class String
  def self.random(length = 10)
    @__avail_chars ||= (('a'..'z').to_a << ("A".."Z").to_a).flatten
    (1..length).inject(""){|out, index| out << @__avail_chars[rand(@__avail_chars.size)]}
  end
end

class Hash
  
  def with( opts )
    self.merge(opts)
  end
  
  def without(*args)
    self.dup.delete_if{ |k,v| args.include?(k)}
  end
  
end