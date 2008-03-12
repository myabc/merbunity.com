require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Merbunity::Permissions::ProtectedModel do
  
  class MyProtectedModel < DataMapper::Base
    include Merbunity::Permissions::ProtectedModel
    attr_reader :owner
    
    def initialize(owner = nil)
      @owner = owner
    end
  end
  
  class ProtectedModelWithoutOwner < DataMapper::Base
    include Merbunity::Permissions::ProtectedModel
    
    def initialize
    end
  end
  
  class TheUserModel
    
    def initialize(opts = {})
      @publisher = opts[:publisher]
    end
    
    def publisher?
      @publisher
    end
  end
  
  before(:all) do
    @user = TheUserModel.new
  end
  
  it "should implement a viewable_by? method" do
    MyProtectedModel.new.should respond_to(:viewable_by?)
  end
  
  it "should be viewable if the user is the owner" do
    mpm = MyProtectedModel.new(@user)    
    mpm.viewable_by?(@user).should be_true
  end
  
  it "should not be viewable if the user is not the owner" do
    mpm = MyProtectedModel.new(@user)
    u = TheUserModel.new
    mpm.viewable_by?(u).should be_false    
  end
  
  it "should implement an editable_by? method" do
    MyProtectedModel.new.should respond_to(:editable_by?)
  end
  
  it "should be editable if the user is the owner" do
    mpm = MyProtectedModel.new(@user)    
    mpm.editable_by?(@user).should be_true
  end
  
  it "should not be editable if the user is not the owner or publisher" do
    mpm = MyProtectedModel.new(@user)
    u = TheUserModel.new(:publisher => false)
    mpm.editable_by?(u).should be_false    
  end
  
  it "should implement a destroyable_by? method" do
    MyProtectedModel.new.should respond_to(:destroyable_by?)
  end  
  
  it "should be destroyable if the user is the owner" do
    mpm = MyProtectedModel.new(@user)    
    mpm.destroyable_by?(@user).should be_true
  end
  
  it "should not be destroyable if the user is not the owner" do
    mpm = MyProtectedModel.new(@user)
    u = TheUserModel.new
    mpm.destroyable_by?(u).should be_false    
  end
  
  it "should return true for an object that is viewable_by?(nil) that is published" do
    mpm = MyProtectedModel.new(@user)   
    mpm.stub!(:published?).and_return true 
    mpm.viewable_by?(nil).should be_true
  end
  
  it "should return false for an object that is viewable_by?(nil) that is not published" do
    mpm = MyProtectedModel.new(@user)
    mpm.stub!(:published?).and_return false
    mpm.viewable_by?(nil).should be_false
  end
  
  it "should return true for veiwable_by? if the user is a publisher" do
    mpm = MyProtectedModel.new(@user)
    mpm.viewable_by?(TheUserModel.new(:publisher => true)).should be_true    
  end
  
end

