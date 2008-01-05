MERB_ENV="test"
$TESTING=true
require File.join(File.dirname(__FILE__), "..", 'config', 'boot')
require File.join(MERB_ROOT, 'config', 'merb_init')

require 'merb/test/helper'
require 'merb/test/rspec'
require (File.dirname(__FILE__) / 'valid_hash_helper')

Spec::Runner.configure do |config|
    config.include(Merb::Test::Helper)
    config.include(Merb::Test::RspecMatchers)
    config.include(ValidHashHelpers)
end
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
