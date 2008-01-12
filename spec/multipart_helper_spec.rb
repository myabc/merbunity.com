require File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'tempfile'

describe MultipartHelper do
  
  before(:each) do
   @mp = Merb::Test::Multipart::Post 
   @file = Tempfile.new("spec_file.stuff")
  end  
  
  it "should setup a multipart request" do
    multipart_request("/", :foo => 'bario')
    controller.params.keys.should include("foo")
    controller.params["foo"].should == "bario"
  end
  
  it "should take a nested hash and do the right thing" do
    multipart_request("/", :foo => "bario", :bar => { :a => "a", :b => "b"})
    controller.params.keys.should include("foo")
    controller.params.keys.should include("bar")
    controller.params["foo"].should == "bario"
    controller.params["bar"].should be_a_kind_of(Mash)
    controller.params["bar"]["a"].should == "a"
    controller.params["bar"]["b"].should == "b"
  end
  
  it "should take a nested hash with a file upload and do the right thing" do
    multipart_request("/", :bar => { :a => 'a', :my_file => @file})
    controller.params.keys.should include('bar')
    controller.params["bar"].keys.should include('a')
    controller.params["bar"].keys.should include('my_file')
    controller.params["bar"]["a"].should == "a"
    
    controller.params["bar"]["my_file"].should be_a_kind_of(Mash)
    
    file_params = controller.params["bar"]["my_file"]
    file_params["filename"].should == @file.path.split("/").last
    file_params["size"].should == 0
    file_params["tempfile"].should be_a_kind_of(File)
  end
  
  it "should expose the controller inside the block" do
    multipart_request("/", :foo => "bar") do
      controller.should_receive(:dispatch).and_return(true)
    end    
  end
end