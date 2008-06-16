require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Merbunity::Permissions::ProtectedModel do
  
  class MyProtectedModel
    include DataMapper::Resource
    include Merbunity::Permissions::ProtectedModel
    attr_reader :owner
    property :id, Integer, :serial => true
    
    def initialize(opts = {})
      @owner = opts[:owner]
      @published = opts[:published]
    end
    
    def published?
      !!@published
    end
    
    def published_on
      return nil unless self.published?
      @published_on ||= Time.now
    end
  end
  
  class TheUserModel
    
    def initialize(opts = {})
      @publisher = opts[:publisher]
      @admin = opts[:admin]
    end
    
    def publisher?
      @publisher
    end
    
    def admin?
      !!@admin
    end
      
  end
  
  before(:all) do
    @owner = TheUserModel.new
    @user = TheUserModel.new
    @admin = TheUserModel.new(:admin => true)
    @publisher = TheUserModel.new(:publisher => true)
    @mpm = MyProtectedModel.new(:owner => @owner, :published => false)
  end
  
  it "should setup the spec properly" do
    @owner.should_not be_publisher
    @owner.should_not be_admin
    @owner.should_not == @user
    @owner.should == @mpm.owner
    
    @user.should_not be_publisher
    @user.should_not be_admin
    @mpm.owner.should_not == @user
    
    @publisher.should_not be_admin
    @mpm.owner.should_not == @publisher
    
    @mpm.owner.should_not == @admin
    
    @mpm.should_not be_published
  end
  
  it "should be veiwable by an admin" do
    @mpm.should be_viewable_by(@admin)
  end
  
  it "should be viewable by the owner who is not an admin or publisher" do 
    @mpm.should be_viewable_by(@owner)
  end
  
  it "should be viewable by a publisher who is not the owner or an admin" do
    @mpm.should be_viewable_by(@publisher)
  end
  
  it "should not be viewable by nil or :false if the item is not published" do
    @mpm.should_not be_viewable_by(nil)
    @mpm.should_not be_viewable_by(:false)
  end
  
  it "should be viewable by nil or false if the item is published" do
    m = MyProtectedModel.new(:owner => @owner, :published => true)
    m.should be_viewable_by(nil)
    m.should be_viewable_by(:false)
  end
  
  it "should be editable by an admin" do
    @mpm.should be_editable_by(@admin)
  end
  
  it "should be editable by the owner who is not an admin" do
    @mpm.should be_editable_by(@owner)
  end
  
  it "should not be editable by a publisher who does not own the model and is not an admin" do
    @mpm.should_not be_editable_by(@publisher)
  end
  
  it "should not be editable by a person who is not admin, owner, publisher" do
    @mpm.should_not be_editable_by(@user)
  end
  
  it "should not be editable by a person who is nil or :false" do
    @mpm.should_not be_editable_by(nil)
    @mpm.should_not be_editable_by(:false)
  end
  
  it "should be destroyable by an admin" do
    @mpm.should be_destroyable_by(@admin)
  end
  
  it "should be destroyable by the owner who is not an admin" do
    @mpm.should be_destroyable_by(@owner)
  end
  
  it "should not be destroyable by the owner who is not an admin if it is / has been published" do
    mpm = MyProtectedModel.new(:owner => @owner, :published => true)
    mpm.should be_destroyable_by(@admin)
    mpm.should_not be_destroyable_by(@publisher)
    mpm.should_not be_destroyable_by(@owner)
  end
  
  it "should not be destroyable by a publisher who does not own the model and is not an admin" do
    @mpm.should_not be_destroyable_by(@publisher)
  end
  
  it "should not be destroyable by a user who is not owner, admin or publisher" do
    @mpm.should_not be_destroyable_by(@user)
  end
  
  it "should not be destroyable_by a user how is nil or :false" do
    @mpm.should_not be_destroyable_by(nil)
    @mpm.should_not be_destroyable_by(:false)
  end
  
  it "should be publishable by an admin" do
    @mpm.should be_publishable_by(@admin)
  end
  
  it "should be publishable by a publisher who is not an admin" do
    @mpm.should be_publishable_by(@publisher)
  end
  
  it "should be publishable by the owner who is not a publisher or admin to pending" do
    @mpm.should be_publishable_by(@owner)
  end
  
  it "should not be publishable by a user who is not a publisher or admin or owner" do
    @mpm.should_not be_publishable_by(@user)
  end
  
  it "should not be publishable by a nil or :false" do
    @mpm.should_not be_publishable_by(nil)
    @mpm.should_not be_publishable_by(:false)
  end
  
  it "should be viewable when a user who is not a publisher, owner or admin and the model is publshed" do
    p = Person.create(valid_person_hash)    
    m = MyProtectedModel.new(:owner => @owner, :published => true)
    m.should be_viewable_by(p)
  end
  
  
  
end

