require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')


describe "Merbunity::Publishable" do
  
  class MyPublishableModel
    include DataMapper::Resource
    include Merbunity::Publishable
    include Merbunity::Permissions::ProtectedModel
    property :id, Integer, :serial => true
    is_commentable(:pending, :published)
  end

  before(:all) do
    DataMapper.auto_migrate!
  end

  before(:each) do
    MyPublishableModel.auto_migrate!
    Person.auto_migrate!
    
    @person = Person.new(valid_person_hash)
    @person.save
    @person.reload
    @p = MyPublishableModel.new(:owner => @person)
    
    @publisher = Person.new(valid_person_hash)    
    @publisher.save
    @publisher.make_publisher!
    @publisher.reload
    
    @other_person = Person.create(valid_person_hash)
    @other_person.reload
    
    1.upto(4) do |i| 
      p = MyPublishableModel.create(:owner => @person) 
      if (i % 2) == 0
        p.publish!(@publisher)  # Make this one published
      else
        p.publish!(@person) # Make this one pending
      end
    end
    
    1.upto(2) do |i| 
      p = MyPublishableModel.create(:owner => @other_person)
      p.publish!(@other_person)
    end
    
    # drafts
    [@publisher, @person, @other_person].each do |p|
      1.upto(3) do |i|
        MyPublishableModel.create(:owner => p)
      end
    end
  end
  
  it "should setup the test correctly" do
    published, pending, drafts = [[],[],[]]
    MyPublishableModel.all.each do |m| 
      published << m if m.published?
      pending << m  if m.pending?
      drafts << m if m.draft?
    end
      
    published.should have(2).items
    pending.should have(4).items
    drafts.should have(9).items
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
    pending("An error on the production servers prevents the owner flag")
    pm = MyPublishableModel.new
    pm.owner.should be_nil
    pm.save
    pm.errors.on(:owner).should_not be_nil
  end
  
  it "should set published_on to nil if the person is not a publisher" do
    @person.should_not be_a_publisher
    pm = MyPublishableModel.new(:owner => @person)    
    pm.save
    pm.published_on.should be_nil
  end
  
  it "should change from draft to pending when an owner non-publisher publishes an item" do
    @person.should_not be_a_publisher
    pm = MyPublishableModel.new(:owner => @person)
    pm.save
    pm.should be_draft
    @person.publish(pm)
    pm.should_not be_draft
    pm.should be_pending    
  end
  
  # it "should set published_on to the date if the person is a publisher" do
  # 
  #   pm = MyPublishableModel.new(:owner => @publisher)
  #   pm.save
  #   pm.published_on.should_not be_nil
  #   pm.published_on.should be_kind_of(DateTime)
  # end
  
  it "should add a pending? method to the model" do
    @p.should respond_to(:pending?)
  end
  
  it "should return false for pending when the model has a published date" do
    p = MyPublishableModel.create(:owner => @publisher)
    p.publish!(@publisher)
    p.should_not be_pending    
  end
  
  it "should return false for published? when pending" do
    p = MyPublishableModel.create(:owner => @person)
    p.publish!(@person)
    p.should be_pending
    p.should_not be_published
  end
  
  it "should return true for published? when not pending" do
    p = MyPublishableModel.create(:owner => @publisher)
    p.publish!(@publisher)
    p.should_not be_pending
    p.should be_published    
  end
  
  it "should publish! and article when told to do so" do
    p = MyPublishableModel.create(:owner => @person)
    p.should_not be_published
    p.publish!(@publisher)
    p.should be_published    
    p.dirty_attributes.should be_empty # It should save it in the publish! action
  end
  
  it "should make a pending method on the class" do
    p = MyPublishableModel.pending
    p.should have(4).items
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
  
  it "should set the publisher when it gets published" do
    p = MyPublishableModel.create(:owner => @person)
    @publisher.publish(p)
    p.publisher.should == @publisher
  end
  
  it "should increase the owners published_item_count when a work of theirs gets published" do
    p = MyPublishableModel.create(:owner => @person)
    lambda do
      @publisher.publish(p)
    end.should change(@person, :published_item_count).by(1)
  end
  
  it "should find all drafts" do    
    MyPublishableModel.drafts.any?{|d| !d.draft?}.should be_false
  end
  
  it "should set a draft? method" do
   MyPublishableModel.new.should respond_to(:draft?)
  end
  
  it "should set a model to draft by default" do
    m = MyPublishableModel.new    
    m.should be_draft
  end
  
  it "should not report that it is pending when its a draft" do
    m = MyPublishableModel.new
    m.should_not be_pending
  end
  
  it "should not be published when it's a draft" do
    m = MyPublishableModel.new
    m.should_not be_published
  end
  
  it "should add a drafts method to the user model" do
    d = @person.draft_my_publishable_models
    d.should have(3).items
    d.all?{|s| s.owner.id == @person.id}.should be_true    
  end
  
  it "should make a person a publisher after a set number of published screencasts" do
    num = MyPublishableModel.publishables_to_be_publisher
    p = Person.create(valid_person_hash)
    pub = Person.create(valid_person_hash)
    pub.make_publisher!
    
    p.should_not be_publisher
    
    1.upto(num - 1){|i| m = MyPublishableModel.create(:owner => p); pub.publish(m) }
    p.should_not be_publisher
    
    m = MyPublishableModel.create(:owner => p)
    pub.publish(m)
    
    p.should be_publisher
  end
  
  it "should have and belong to many pending comments" do
    DataMapper.auto_migrate!
    Comment.all.size.should == 0
    Person.all.size.should == 0
    MyPublishableModel.all.size.should == 0
    
    p = Person.create(valid_person_hash)
    
    m = MyPublishableModel.create(:owner => p)
    c = Comment.create(valid_comment_hash)
    
    m.pending_comments << c
    m.pending_comments.size.should == 1
    m.save!
    
    # database.adapter.connection do |db|
    #   blah= db.create_command("SELECT * FROM comments_my_publishable_models")
    #   blah.execute_reader do |reader|
    #     reader.each do
    #       puts reader.current_row.inspect
    #     end
    #   end
    # end
    
    m.reload!
    m.should have(1).pending_comments
    
    z = MyPublishableModel[m.id]
    z.should have(1).pending_comments
  end
  
  it "should have and belong to many comments" do
    DataMapper.auto_migrate!
    p = Person.create(valid_person_hash)
    m = MyPublishableModel.create(:owner => p)
    c = Comment.create(valid_comment_hash)
    m.comments << c
    m.should have(1).comments
    m.save
    
    z = MyPublishableModel[m.id]
    z.should have(1).comments
  end

  it "should not mix pending and normal comments" do
    m = MyPublishableModel.create(:owner => @person)
    c = Comment.create(valid_comment_hash.with(:owner => @person))
    pc = Comment.create(valid_comment_hash.with(:owner => @person))
    m.comments << c
    m.pending_comments << pc
    m.save
    
    k = MyPublishableModel[m.id]
    k.comments.should include(c)
    k.pending_comments.should include(pc)
  
    k.comments.should_not include(pc)
    k.pending_comments.should_not include(c)
  end
end


describe Merbunity::PublishableController do
  
  class PublishableModel
    include DataMapper::Resource
    include Merbunity::Publishable
    include Merbunity::Permissions::ProtectedModel
    property :id, Integer, :serial => true
  end
  
  class PublishableController < Application
    publishable_resource PublishableModel
    skip_before :non_publisher_help
  end
  
  before(:all) do
    PublishableModel.auto_migrate!
    Person.auto_migrate!
  end
  
  before(:each) do
    @person = Person.create(valid_person_hash)
    PublishableModel.auto_migrate!
  end
  
  it "should setup the specs properly" do
    PublishableController.should include(AuthenticatedSystem::Controller)
  end

  it "should add publishable_resource to Merb::Controller" do
    Merb::Controller.should respond_to(:publishable_resource)    
  end
  
  it "should add these class attributes" do
    [:publishable_klass, :publishable_collection_ivar_name].each do |cvar|
      PublishableController.instance_variable_defined?("@#{cvar}")
    end
  end
  
  it "should raise an error if what is passed does not include Merbunity::Publishable" do
    class One
      include DataMapper::Resource
      property :id, Integer, :serial => true
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
  
  it "should set the publishable_klass for the controller" do
    PublishableController.publishable_klass.should == PublishableModel    
  end
  
  it "should get the index of pending objects for a user if they are not a publisher" do
    p = Person.create(valid_person_hash)
    p.should_not be_a_publisher
    1.upto(3){ pm = PublishableModel.create(:owner => p); p.publish(pm)}
    
    @person.should_not be_a_publisher
    1.upto(2){ z = PublishableModel.create(:owner => @person); z.publish!(@person)}
    
    c = dispatch_to(PublishableController, :pending) do |controller|
      controller.stub!(:display).and_return("DISPLAYED")
      controller.stub!(:current_person).and_return(@person)
    end
    result = c.assigns(:publishable_models)
    result.should_not be_nil
    result.should have(2).items
    result.each{|r| r.owner.id.should == @person.id}
  end
  
  it "should get the index of all pending objects for a user if they are a publisher" do
    p = Person.create(valid_person_hash)
    [@person, p].each do |dude|
      dude.should_not be_a_publisher
      1.upto(3){ i = PublishableModel.create(:owner => dude); dude.publish(i); i.should be_pending; i.should_not be_a_new_record}
    end
    
    publisher = Person.create(valid_person_hash)
    publisher.make_publisher!
    
    c = dispatch_to(PublishableController, :pending) do |controller|
      controller.stub!(:display).and_return("DISPLAYED")
      controller.stub!(:current_person).and_return(publisher)
    end
    result = c.assigns(:publishable_models)
    result.should_not be_nil
    result.should have(6).items
    result.any?{|m| m.owner != publisher}.should be_true
  end
  
  it "should limit the number of pending results to 10" do
    pub = Person.create(valid_person_hash)
    pub.make_publisher!
    p = Person.create(valid_person_hash)
    
    1.upto(11){z = PublishableModel.create(:owner => p); p.publish(z)}
    c = dispatch_to(PublishableController, :pending) do |controller|
      controller.stub!(:display).and_return("DISPLAYED")
      controller.stub!(:current_person).and_return(pub)
    end
    result = c.assigns(:publishable_models)
    result.should_not be_nil
    result.should have(10).items
  end

  it "should require login" do
    c = dispatch_to(PublishableController, :pending)
    c.should redirect_to(url(:login))    
  end
  
  it "should require login for drafts" do
    c = dispatch_to(PublishableController, :drafts)    
    c.should redirect_to(url(:login))
  end
  
  it "should be successful when a user logs in" do
    p = Person.create(valid_person_hash)
    c = dispatch_to(PublishableController, :drafts){|c| c.stub!(:current_person).and_return p; c.stub!(:display).and_return true}
    c.should be_successful    
  end
  
  it "should assign the persons drafts to the right ivar" do
    p = Person.create(valid_person_hash)
    1.upto(6){ PublishableModel.create(:owner => p)}
    c = dispatch_to(PublishableController, :drafts) do |c| 
      c.stub!(:current_person).and_return p
      c.stub!(:display).and_return true
    end
    c.assigns(:publishable_models).should == p.draft_publishable_models
  end
end