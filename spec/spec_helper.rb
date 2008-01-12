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
    config.include(Merb::Test::Multipart::TestHelper)
    config.include(ValidHashHelpers)
    config.include(AuthorSpecHelper)
    config.before(:each) do
      
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


module Merb
  module Test
    module Helper
      
      def request(verb, path)
        response = StringIO.new
        request = Merb::Test::FakeRequest.with(path, :request_method => (verb.to_s.upcase rescue 'GET'))
        @request = Merb::Request.new(request)
        
        if @request.route_params.empty?
          raise ControllerExceptions::BadRequest, "No routes match the request"
        elsif @request.controller_name.nil?
          raise ControllerExceptions::BadRequest, "Route matched, but route did not specify a controller" 
        end
        
        klass = request.controller_class
        @controller = klass.build(@request, response, 200)
        
        @controller.send(:setup_session)
        @controller.stub!(:setup_session).and_return(true)
        
        yield @controller if block_given?
        @controller.dispatch(@request.action)
        
      end
      
    end
  end
end
