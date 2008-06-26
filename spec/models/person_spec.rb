require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Person, "in merbcasts" do
  include PersonSpecHelper
  
  before(:each) do
    Person.auto_migrate!
    
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
    
    @person = Person.new(valid_person_hash)
    @person.save
  end
  
  it "should set published_item_count to 0 by default" do
    @person.published_item_count.should == 0    
  end
  
  it "should have many screencasts" do
    person = Person.new(valid_person_hash)
    person.should respond_to(:screencasts)
  end
  
  it "should be made a publisher" do
    hash = valid_person_hash
    person = Person.new(hash)
    person.save
    person.activate
    person.should be_active
    person.make_publisher!
    person.should be_publisher    
  end
  
  it "should persist the publisher status" do
    @publisher.should be_publisher
    publisher = Person.first_publisher(:login => @publisher.login)
    publisher.should_not be_nil
    publisher.should be_publisher
  end
  
  it "should not say that an person is a publisher if they have not yet been made a publisher" do
    person = Person.new(hash)
    person.save
    person.activate
    person.should_not be_publisher
  end
  
  it "should have a publish method that tells the obj to publish" do
    person = Person.new(hash)    
    person.save
    person.activate
    person.make_publisher!
    obj = mock("Publishable object")
    obj.should_receive(:publishable_by?).with(person).and_return true
    obj.should_receive(:publish!).with(person).and_return true
    person.publish(obj)
  end
  
  it "should return true for can_edit? if there is no editable_by? method on the target" do
    obj = Object.new
    obj.should_not respond_to(:editable_by?)
    @person.can_edit?(obj).should be_true
  end
  
  class EditableTest
    def initialize(value)
      @response = value
    end
    def editable_by?(user)
      @response
    end
  end
  
  it "should return the value of :editable_by? if it responds to it" do
    @person.can_edit?(EditableTest.new(true)).should be_true
    @person.can_edit?(EditableTest.new(false)).should be_false    
  end
  
  it "should have an attribute_to method" do
    @person.attribute_to.should == @person.login
  end
  
end