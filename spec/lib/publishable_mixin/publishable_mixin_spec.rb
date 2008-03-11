require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe "Merbunity::Publishable" do
  
  class MyPublishableModel < DataMapper::Base
    include Merbunity::Publishable
  end
  

  
  before(:each) do
    MyPublishableModel.auto_migrate!
    Person.auto_migrate!
    @person = Person.new(valid_person_hash)
    @person.save
    @p = MyPublishableModel.new(:owner => @person)
    
    @publisher = Person.new(valid_person_hash)    
    @publisher.save
    @publisher.make_publisher!
    
    1.upto(4){ |i| p = MyPublishableModel.new(:owner => @person); p.save; p.publish! if (i % 2) == 0 }
  end
  
  it "should setup the test correctly" do
    published, pending = MyPublishableModel.all.partition{|m| m.published?}
    published.should have(2).items
    pending.should have(2).items
  end
  
  it "should add a pending_publishable_model to the person model - for the PublishableModel class" do
     Person.new.should respond_to(:pending_my_publishable_models)    
   end
   
  it "should not return published models in pending_publishable_models" do
    pending = @person.pending_my_publishable_models
    pending.should have(2).items
    pending.each{ |m| m.should_not be_published }
  end
  
  it "should return only published model with publishable_models" do
    pub = @person.published_my_publishable_models
    pub.should have(2).items
    pub.each{|m| m.should be_published}
  end
  
  it "should validate that a Publishable Model has an owner" do
    pm = MyPublishableModel.new
    pm.owner.should be_nil
    pm.save
    pm.errors.on(:owner).should_not be_empty
  end
  
  it "should set published_on to nil if the person is not a publisher" do
    @person.should_not be_a_publisher
    pm = MyPublishableModel.new(:owner => @person)    
    pm.save
    pm.published_on.should be_nil
  end
  
  it "should set published_on to the date if the person is a publisher" do

    pm = MyPublishableModel.new(:owner => @publisher)
    pm.save
    pm.published_on.should_not be_nil
    pm.published_on.should be_kind_of(DateTime)
  end
  
  it "should add a pending? method to the model that returns true when published_on is nil" do
    @p.published_on.should be_nil
    @p.should be_pending
  end
  
  it "should return false for pending when the model has a published date" do
    p = MyPublishableModel.create(:owner => @publisher)
    p.should_not be_pending    
  end
  
  it "should return false for published? when pending" do
    p = MyPublishableModel.create(:owner => @person)
    p.should be_pending
    p.should_not be_published
  end
  
  it "should return true for published? when not pending" do
    p = MyPublishableModel.create(:owner => @publisher)
    p.should_not be_pending
    p.should be_published    
  end
  
  it "should publish! and article when told to do so" do
    p = MyPublishableModel.create(:owner => @person)
    p.should_not be_published
    p.publish!
    p.should be_published    
    p.dirty_attributes.should be_empty # It should save it in the publish! action
  end
  
  it "should make a pending method on the class" do
    p = MyPublishableModel.pending
    p.should have(2).items
    p.each{|m| m.should be_pending}
  end
  
  it "should make a published method on the class" do
    p = MyPublishableModel.published
    p.should have(2).items
    p.each{ |m| m.should be_published }
  end
  
  it "should find a published model on a class with a published id" do
    p = MyPublishableModel.find_published(MyPublishableModel.published.first.id)
    p.should be_published    
  end
  
  it "should not find a pending model via MyPublishableModel.find_published" do
    p = MyPublishableModel.find_published(MyPublishableModel.pending.first.id)
    p.should be_nil    
  end
end


describe Merbunity::PublishableController do
  
  before(:each) do
    @person = Person.create(valid_person_hash)
  end
  
  
  it "should add publishable_resource to Merb::Controller" do
    Merb::Controller.should respond_to(:publishable_resource)    
  end
  
  class PublishableModel < DataMapper::Base
    include Merbunity::Publishable
  end
  
  class PublishableController < Merb::Controller
    publishable_resource PublishableModel
  end
  
  PublishableModel.auto_migrate!
  
  
  it "should add these class attributes" do
    [:publishable_klass, :publishable_collection_ivar_name].each do |cvar|
      PublishableController.instance_variable_defined?("@#{cvar}")
    end
  end
  
  it "should raise an error if what is passed does not include Merbunity::Publishable" do
    class One < DataMapper::Base
    end
    lambda do
      class GoodToGo < Merb::Controller
        publishable_resource One
      end
    end.should raise_error("Must set a publishable_klass in your controller that includes Merbunity::Publishable")
  end
  
  it "should include Merbunity::PublishableController::Setup in the controller" do
    PublishableController.should include(Merbunity::PublishableController::Setup)    
  end
  
  it "should give the controller an available action pending" do
    PublishableController.new(fake_request).should respond_to(:pending)    
  end
  
  it "should add a method to Person for the pending stuff" do
    Person.new.should respond_to(:pending_publishable_models)    
  end
  
  it "should get the index of pending objects for a user if they are not a publisher" do
    @person.should_not be_a_publisher
    c = dispatch_to(PublishableController, :pending) do |controller|
      controller.stub!(:current_user).and_return(@person)
    end
  end
  
  
  
  it "should get the index of all pending objects for a user if they are a publisher"
  
  it "should require login"

end