require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "User Model Permissions System" do
  
  class TheUserModel 
    include Merbunity::Permissions::User
  end
  
  class ThePermissionObject
    def initialize(opts)
      @viewable = opts.delete(:viewable)
      @editable = opts.delete(:editable)
      @destroyable = opts.delete(:destroyable)
    end
    
    def viewable_by?(user);     @viewable;    end
    def editable_by?(user);     @editable;    end
    def destroyable_by?(user);  @destroyable; end
      
  end
  
  before(:all) do 
    @user = TheUserModel.new
  end
  
  it "should ask the object if it can be viewed by this user" do
    p = ThePermissionObject.new(:viewable => true)
    p.should_receive(:viewable_by?).with(@user)
    @user.can_view?(p)
  end
  
  it "should return the value of the objects method viewable_by?" do
    [true,false].each do |v|
      p = ThePermissionObject.new(:viewable => v)
      @user.can_view?(p).should == v
    end      
  end
  
  it "should return true if the object does not support the viewable_by? method" do
    o = Object.new
    o.should_not respond_to(:viewable_by?)
    
    @user.can_view?(o).should be_true
  end
  
  it "should ask the object if it can be edited by this user" do
    p = ThePermissionObject.new(:editable => true)
    p.should_receive(:editable_by?).with(@user)
    @user.can_edit?(p)
  end
  
  it "should return the value of the objects method editable_by?" do
    [true,false].each do |v|
      p = ThePermissionObject.new(:editable => v)
      @user.can_edit?(p).should == v
    end      
  end
  
  it "should return true if the object does not support the editable_by? method" do
    o = Object.new
    o.should_not respond_to(:editable_by?)
    
    @user.can_edit?(o).should be_true
  end
  
  it "should ask the object if it can be destroyed by this user" do
    p = ThePermissionObject.new(:destroyable => true)
    p.should_receive(:destroyable_by?).with(@user)
    @user.can_destroy?(p)
  end
  
  it "should return the value of the objects method destroyable_by?" do
    [true,false].each do |v|
      p = ThePermissionObject.new(:destroyable => v)
      @user.can_destroy?(p).should == v
    end      
  end
  
  it "should return true if the object does not support the destroyable_by? method" do
    o = Object.new
    o.should_not respond_to(:destroyable_by?)
    
    @user.can_destroy?(o).should be_true
  end
  
end