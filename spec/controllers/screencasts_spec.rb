require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Screencasts, "index action" do
  
  before(:all) do
    Person.auto_migrate!
    Screencast.auto_migrate!
    @person1 = Person.create(valid_person_hash)
    @person2 = Person.create(valid_person_hash)
    
    @publisher = Person.create(valid_person_hash)
    @publisher.make_publisher!
    
    [@person1, @person2].each do |p|
      1.upto(10) do |i|
        s = Screencast.new(valid_screencast_hash.with(:owner => p) )
        s.save
        if (i % 2) == 0
          s.publish!(@publisher) 
        else
          s.publish!(p)
        end
      end
    end
    
       
  end
  
  before(:each) do
    @c = dispatch_to(Screencasts, :index)
    @expected = Screencast.published(:limit => 10)
  end
  
  it "should set the specs correctly" do
    published = Screencast.published    
    pending = Screencast.pending
    
    published.should have(10).items
    pending.should have(10).items
  end
  
  it "should not require login" do
    @c.should_not redirect_to(url(:login))
  end
  
  it "should return the 10 latest published screencasts sorted by published_on" do
    @c = dispatch_to(Screencasts, :index)
    @c.assigns(:screencasts).should == @expected        
  end
end

describe Screencasts, "show action" do
  before(:all) do
    Person.auto_migrate!
    Screencast.auto_migrate!
    
    @p1 = Person.create(valid_person_hash)
    @p2 = Person.create(valid_person_hash)
    
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
    
    [@p1, @p2].each do |p|
      1.upto(5) do |i| 
        s = Screencast.new(valid_screencast_hash.with(:owner => p) )
        s.save
        if (i % 2) == 0
          s.publish!(@pub) 
        else
          s.publish!(p)
        end
      end
    end
    

  end
  
  before(:each) do
    # @c = dispatch_to(Screencast, :show, :id => Screencast.published.first)
  end
  
  it "should setup the spec properly" do
    Screencast.published.should have(4).items
    Screencast.pending.should have(6).items
    
    @p1.should_not  be_a_publisher
    @p1.should_not  be_a_publisher
    @pub.should     be_a_publisher
  end
  
  it "should show a published screencast" do
    s = Screencast.published.first
    c = dispatch_to(Screencasts, :show, :id => s.id)
    c.should be_successful
    c.assigns(:screencast).should == s
  end
  
  it "should render a not found error if there is no screencast found" do
    Screencast.should_receive(:find).and_return nil
    lambda do
      c = dispatch_to(Screencasts, :show, :id => 12345)
    end.should raise_error( Merb::Controller::NotFound)
  end
  
  it "should display the screencast" do
    s = Screencast.published.first
    c = dispatch_to(Screencasts, :show, :id => s.id) do |c|
      c.should_receive(:display).with(s)
    end
  end
  
  it "should check that the screencast can be viewed" do
    ms = mock("screencast", :null_object => true)
    ms.stub!(:id).and_return(234)
    ms.should_receive(:viewable_by?).and_return true
    Screencast.should_receive(:find).and_return ms
    dispatch_to(Screencasts, :show, :id => ms.id)
  end
  
  it "should raise an error if the screencast cannot be viewed" do
    ms = mock("screencast", :null_object => true)
    ms.stub!(:id).and_return 345
    ms.should_receive(:viewable_by?).and_return false
    Screencast.should_receive(:find).and_return ms
    lambda do
      dispatch_to(Screencasts, :show, :id => ms.id)
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  
end

describe Screencasts, "edit action" do
  before(:all) do
    Person.auto_migrate!
    @p = Person.create(valid_person_hash)
  end
  
  before(:each) do
    Screencast.auto_migrate!
    @s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    @s.save
  end
  
  it "should redirect to login if the user is not logged in" do
    c = dispatch_to(Screencasts, :edit, :id => @s.id)  
    c.should redirect_to(url(:login))     
  end
  
  it "should ask the object if the current user can edit it" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))    
    s.save
    Screencast.should_receive(:first).with(s.id.to_s).and_return(s)
    dispatch_to(Screencasts, :edit, :id => s.id) do |c|
      c.stub!(:current_person).and_return @p
      s.should_receive(:editable_by?).with(@p).and_return true
    end    
  end
  
  it "should show the edit form if the screencast can be edited by the current person" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    s.save
    s.should_receive(:editable_by?).with(@p).and_return true
    Screencast.should_receive(:first).with(s.id.to_s).and_return(s)
    c = dispatch_to(Screencasts, :edit, :id => s.id) do |c|
      c.stub!(:current_person).and_return @p
    end
    c.should be_successful    
  end
  
  it "should raise an error when the screncast is not editable by this person" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return false
    Screencast.should_receive(:first).with(s.id.to_s).and_return(s)
    lambda do
      dispatch_to(Screencasts, :edit, :id => s.id) do |c|
        c.stub!(:current_person).and_return @p
      end
    end.should raise_error(Merb::Controller::Unauthorized)
  end
end

describe Screencasts, "update action" do
  before(:all) do
    Person.auto_migrate!
    @p = Person.create(valid_person_hash)
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
  end
  
  before(:each) do
    Screencast.auto_migrate!
    @s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    @s.save
  end
  
  it "should require a user to be logged in" do
    c = dispatch_to(Screencasts, :update, :id => @s.id, :screencast => {:title => "My Title"})
    c.should redirect_to(url(:login))
  end
  
  it "should raise a not found error if the screencast does not exist" do
    lambda do
      dispatch_to(Screencasts, :update, :id => 999, :screencast => {:title => "my title"}) do |c|
        c.stub!(:current_person).and_return(@p)
      end 
    end.should raise_error(Merb::Controller::NotFound)    
  end
  
  it "should ask the screencast if it is editable by the current person" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return true
    Screencast.should_receive(:first).and_return(s)
    dispatch_to(Screencasts, :update, :id => 123, :screencast => {:title => "blah"}) do |c|
      c.stub!(:current_person).and_return @p
    end
  end
  
  it "should raise an error if the screencast is not editable by the current person" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    s.save
    s.should_receive(:editable_by?).with(@p).and_return false
    Screencast.should_receive(:first).and_return s
    lambda do
      dispatch_to(Screencasts, :update, :id => 123, :screencast => {:title => "blah"}) do |c|
        c.stub!(:current_person).and_return @p
      end
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  it "should update the screencast with the attributes given" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return true
    Screencast.should_receive(:first).and_return s
    attrs = {:title => "My New Title"}
    s.should_receive(:update_attributes) do |args|
      args['title'].should == "My New Title"
      true
    end
    
    c = dispatch_to(Screencasts, :update, :id => s.id, :screencast => attrs) do |c|
      c.stub!(:current_person).and_return(@p)
    end
    c.should redirect_to(url(:screencast, s))
  end
  
  it "should render the edit action if the update_attributes does not work" do
    s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    s.save    
    s.should_receive(:editable_by?).and_return(true)
    s.should_receive(:update_attributes).and_return false
    Screencast.should_receive(:first).and_return s
    attrs = {:title => "My New Title"}
    c = dispatch_to(Screencasts, :update, :id => s.id, :screencast => attrs) do |c|
      c.stub!(:current_person).and_return @p
      c.should_receive(:render).with(:edit)
    end
  end
  
  it "should strip the :owner attribute from the params hash" do
    s = Screencast.new(valid_person_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).and_return(true)
    s.should_receive(:update_attributes) do |args|
      args['owner'].should be_nil
      args[:owner].should be_nil
      true
    end
    Screencast.should_receive(:first).and_return s
    attrs = {:title => "My Titel", :owner => 1}
    c = dispatch_to(Screencasts, :update, :id => s.id, :screencast => attrs ) do |c|
      c.stub!(:current_person).and_return @p
    end
    c.params[:screencast][:title].should_not be_nil
    c.params[:screencast][:owner].should be_nil
  end
end

describe Screencasts, "delete action" do
  before(:all) do
    Person.auto_migrate!
    @p= Person.create valid_person_hash
  end
  
  before(:each) do
    Screencast.auto_migrate!
    @s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    @s.save
  end
  
  it "should not execute the action without being logged in" do
    c = dispatch_to(Screencasts, :destroy, :id => @s.id)
    c.should redirect_to(url(:login))
  end

  it "should raise a not found error if the screencast cannot be found" do
    lambda do
      dispatch_to(Screencasts, :destroy, :id => 99854) do |c|
        c.stub!(:current_person).and_return(@p)
      end
    end.should raise_error(Merb::Controller::NotFound)
  end
  
  it "should ask the screencast if it can be destroyed by the current person" do
    @s.should_receive(:destroyable_by?).and_return(true)
    Screencast.should_receive(:first).and_return(@s)
    dispatch_to(Screencasts, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}
  end
  
  it "should raise an unauthorized error if it can't be destroyed by the current person" do
    @s.should_receive(:destroyable_by?).and_return(false)
    Screencast.should_receive(:first).and_return(@s)
    lambda do
      dispatch_to(Screencasts, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}    
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  it "should redirect to url(:screencasts) if the delete is successful" do
    @s.should_receive(:destroyable_by?).and_return(true)    
    Screencast.should_receive(:first).and_return(@s)
    c = dispatch_to(Screencasts, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}
    c.should redirect_to(url(:screencasts))
  end
  
  
end

describe Screencasts, "Publishable Actions" do
  
  before(:all){ @klass = Screencasts }
  
  it_should_behave_like "a controller that implements the publishable mixin"
    
  it "should implement the  publishable controller mixin" do
    Screencasts.should include(Merbunity::PublishableController::Setup)    
    Screencasts.publishable_klass.should == Screencast
  end
end