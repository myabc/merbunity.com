require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Screencasts, "index action" do
  
  before(:all) do
    Person.auto_migrate!
    @person1 = Person.create(valid_person_hash)
    @person2 = Person.create(valid_person_hash)
    
    [@person1, @person2].each do |p|
      1.upto(10) do |i|
        s = Screencast.new(valid_screencast_hash.with(:owner => p) )
        s.save
        s.publish! if (i % 2) == 0
      end
    end
        
    @publisher = Person.create(valid_person_hash)
    @publisher.make_publisher!    
  end
  
  before(:each) do
    @c = dispatch_to(Screencasts, :index)
    @expected = Screencast.published(:limit => 10)
  end
  
  it "should set the specs correctly" do
    @person1.should_not be_publisher
    @person2.should_not be_publisher
    @publisher.should be_publisher    
    
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
    
    [@p1, @p2].each do |p|
      1.upto(5){|i| s = Screencast.new(valid_screencast_hash.with(:owner => p) );s.save; s.publish! if (i % 2) == 0;}
    end
    
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
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
    Screencast.should_receive(:find_published).and_return nil
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
    Screencast.should_receive(:find_published).and_return ms
    dispatch_to(Screencasts, :show, :id => ms.id)
  end
  
  it "should raise an error if the screencast cannot be viewed" do
    ms = mock("screencast", :null_object => true)
    ms.stub!(:id).and_return 345
    ms.should_receive(:viewable_by?).and_return false
    Screencast.should_receive(:find_published).and_return ms
    lambda do
      dispatch_to(Screencasts, :show, :id => ms.id)
    end.should raise_error(Merb::Controller::NotFound)
  end
  
  
end

describe Screencasts, "edit action" do
  before(:all) do
    Person.auto_migrate!
    Screencast.auto_migrate!
    @p = Person.create(valid_person_hash)
    
    @s = Screencast.new(valid_screencast_hash.with(:owner => @p))
    @s.save
  end
  
  it "should redirect to login if the user is not logged in" do
    c = dispatch_to(Screencasts, :edit, :id => @s.id)  
    c.should redirect_to(url(:login))     
  end
  
  it "should show the edit form if the person is logged in and the owner of the cast" do
    c = dispatch_to(Screencasts, :edit, :id => @s.id) do |c|
      c.stub!(:current_person).and_return @p
    end
    
    
  end
  
  
  
end
# 
# describe Screencasts, "update action" do
#   before(:each) do
#     @controller dispatch_to(Screencasts, :index)
#   end
# end
# 
# describe Screencasts, "delete action" do
#   before(:each) do
#     @controller dispatch_to(Screencasts, :index)
#   end
# end
# 
# describe Screencasts, "Pending Actions" do
#   before(:each) do
#     @controller dispatch_to(Screencasts, :index)
#   end
# end