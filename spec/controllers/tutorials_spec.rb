require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Tutorials, "index action" do
  
  before(:all) do
    Person.auto_migrate!
    Tutorial.auto_migrate!
    Tutorial.publishables_to_be_publisher(5)
    
    @person1 = Person.create(valid_person_hash)
    @person2 = Person.create(valid_person_hash)
    
    @publisher = Person.create(valid_person_hash)
    @publisher.make_publisher!
    
    [@person1, @person2].each do |p|
      1.upto(10) do |i|
        s = Tutorial.new(valid_tutorial_hash.with(:owner => p) )
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
    @c = dispatch_to(Tutorials, :index) 
    @expected = Tutorial.published(:limit => 10)
  end
  
  it "should set the specs correctly" do
    published = Tutorial.published
    pending = Tutorial.pending
    published.should have(10).items
    pending.should have(10).items
   end
  
  it "should not require login" do
    @c.should_not redirect_to(url(:login))
  end
  
  it "should return the 10 latest published tutorials sorted by published_on" do
    @c = dispatch_to(Tutorials, :index)
    @c.assigns(:tutorials).should == @expected        
  end
end

describe Tutorials, "show action" do
  before(:all) do
    Person.auto_migrate!
    Tutorial.auto_migrate!
    
    @p1 = Person.create(valid_person_hash)
    @p2 = Person.create(valid_person_hash)
    
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
    
    [@p1, @p2].each do |p|
      1.upto(5) do |i| 
        s = Tutorial.new(valid_tutorial_hash.with(:owner => p) )
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
    # @c = dispatch_to(Tutorial, :show, :id => Tutorial.published.first)
  end
  
  it "should setup the spec properly" do
    Tutorial.published.should have(4).items
    Tutorial.pending.should have(6).items
    
    @p1.should_not  be_a_publisher
    @p1.should_not  be_a_publisher
    @pub.should     be_a_publisher
  end
  
  it "should show a published tutorial" do
    s = Tutorial.published.first
    c = dispatch_to(Tutorials, :show, :id => s.id)
    c.should be_successful
    c.assigns(:tutorial).should == s
  end
  
  it "should render a not found error if there is no tutorial found" do
    Tutorial.should_receive(:first).and_return nil
    lambda do
      c = dispatch_to(Tutorials, :show, :id => 12345)
    end.should raise_error( Merb::Controller::NotFound)
  end
  
  it "should display the tutorial" do
    s = Tutorial.published.first
    c = dispatch_to(Tutorials, :show, :id => s.id) do |c|
      c.should_receive(:display).with(s)
    end
  end
  
  it "should check that the tutorial can be viewed" do
    ms = mock("tutorial", :null_object => true)
    ms.stub!(:id).and_return(234)
    ms.should_receive(:viewable_by?).and_return true
    Tutorial.should_receive(:first).and_return ms
    dispatch_to(Tutorials, :show, :id => ms.id)
  end
  
  it "should raise an error if the tutorial cannot be viewed" do
    ms = mock("tutorial", :null_object => true)
    ms.stub!(:id).and_return 345
    ms.should_receive(:viewable_by?).and_return false
    Tutorial.should_receive(:first).and_return ms
    lambda do
      dispatch_to(Tutorials, :show, :id => ms.id)
    end.should raise_error(Merb::Controller::Unauthorized)
  end
end

describe Tutorials, "edit action" do
  before(:all) do
    Person.auto_migrate!
    @p = Person.create(valid_person_hash)
  end
  
  before(:each) do
    Tutorial.auto_migrate!
    @s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    @s.save
  end
  
  it "should redirect to login if the user is not logged in" do
    c = dispatch_to(Tutorials, :edit, :id => @s.id)  
    c.should redirect_to(url(:login))     
  end
  
  it "should ask the object if the current user can edit it" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))    
    s.save
    Tutorial.should_receive(:first).with(s.id.to_s).and_return(s)
    dispatch_to(Tutorials, :edit, :id => s.id) do |c|
      c.stub!(:current_person).and_return @p
      s.should_receive(:editable_by?).any_number_of_times.with(@p).and_return true
    end    
  end
  
  it "should show the edit form if the tutorial can be edited by the current person" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    s.save
    s.should_receive(:editable_by?).any_number_of_times.with(@p).and_return true
    Tutorial.should_receive(:first).with(s.id.to_s).and_return(s)
    c = dispatch_to(Tutorials, :edit, :id => s.id) do |c|
      c.stub!(:current_person).and_return @p
    end
    c.should be_successful    
  end
  
  it "should raise an error when the screncast is not editable by this person" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return false
    Tutorial.should_receive(:first).with(s.id.to_s).and_return(s)
    lambda do
      dispatch_to(Tutorials, :edit, :id => s.id) do |c|
        c.stub!(:current_person).and_return @p
      end
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  it "should show an edit form" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    s.save
    Tutorial.should_receive(:first).with(s.id.to_s).and_return(s)
    s.should_receive(:editable_by?).any_number_of_times.with(@p).and_return true
    controller = dispatch_to(Tutorials, :edit, :id => s.id) do |c|
      c.stub!(:current_person).and_return @p
    end
    controller.body.should have_tag(:form, 
                                    :action => url(:tutorial, :id => s.id), 
                                    :method => "post") #do |d|
      #   d.should have_tag(:input, :type => "hidden", :name => "_method", :value => "put")
      #   d.should match_selector('input[@name*="title"]')
      #   d.should match_selector('textarea[@name*="description"]')
      #   d.should match_selector('textarea[@name*="body"]')
      #   d.should match_selector('input[@type="file"][@name*="uploaded_file"]')
      # end
  end
end

describe Tutorials, "update action" do
  before(:all) do
    Person.auto_migrate!
    @p = Person.create(valid_person_hash)
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
  end
  
  before(:each) do
    Tutorial.auto_migrate!
    @s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    @s.save
  end
  
  it "should require a user to be logged in" do
    c = dispatch_to(Tutorials, :update, :id => @s.id, :tutorial => {:title => "My Title"})
    c.should redirect_to(url(:login))
  end
  
  it "should raise a not found error if the tutorial does not exist" do
    lambda do
      dispatch_to(Tutorials, :update, :id => 999, :tutorial => {:title => "my title"}) do |c|
        c.stub!(:current_person).and_return(@p)
      end 
    end.should raise_error(Merb::Controller::NotFound)    
  end
  
  it "should ask the tutorial if it is editable by the current person" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return true
    Tutorial.should_receive(:first).and_return(s)
    dispatch_to(Tutorials, :update, :id => 123, :tutorial => {:title => "blah"}) do |c|
      c.stub!(:current_person).and_return @p
    end
  end
  
  it "should raise an error if the tutorial is not editable by the current person" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    s.save
    s.should_receive(:editable_by?).with(@p).and_return false
    Tutorial.should_receive(:first).and_return s
    lambda do
      dispatch_to(Tutorials, :update, :id => 123, :tutorial => {:title => "blah"}) do |c|
        c.stub!(:current_person).and_return @p
      end
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  it "should update the tutorial with the attributes given" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).with(@p).and_return true
    Tutorial.should_receive(:first).and_return s
    attrs = {:title => "My New Title"}
    s.should_receive(:update_attributes) do |args|
      args['title'].should == "My New Title"
      true
    end
    
    c = dispatch_to(Tutorials, :update, :id => s.id, :tutorial => attrs) do |c|
      c.stub!(:current_person).and_return(@p)
    end
    c.should redirect_to(url(:tutorial, s))
  end
  
  it "should render the edit action if the update_attributes does not work" do
    s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    s.save    
    s.should_receive(:editable_by?).and_return(true)
    s.should_receive(:update_attributes).and_return false
    Tutorial.should_receive(:first).and_return s
    attrs = {:title => "My New Title"}
    c = dispatch_to(Tutorials, :update, :id => s.id, :tutorial => attrs) do |c|
      c.stub!(:current_person).and_return @p
      c.should_receive(:render).with(:edit)
    end
  end
  
  it "should strip the :owner attribute from the params hash" do
    s = Tutorial.new(valid_person_hash.with(:owner => @p))    
    s.save
    s.should_receive(:editable_by?).and_return(true)
    s.should_receive(:update_attributes) do |args|
      args['owner'].should be_nil
      args[:owner].should be_nil
      true
    end
    Tutorial.should_receive(:first).and_return s
    attrs = {:title => "My Titel", :owner => 1}
    c = dispatch_to(Tutorials, :update, :id => s.id, :tutorial => attrs ) do |c|
      c.stub!(:current_person).and_return @p
    end
    c.params[:tutorial][:title].should_not be_nil
    c.params[:tutorial][:owner].should be_nil
  end
end

describe Tutorials, "delete action" do
  before(:all) do
    Person.auto_migrate!
    @p= Person.create valid_person_hash
  end
  
  before(:each) do
    Tutorial.auto_migrate!
    @s = Tutorial.new(valid_tutorial_hash.with(:owner => @p))
    @s.save
  end
  
  it "should not execute the action without being logged in" do
    c = dispatch_to(Tutorials, :destroy, :id => @s.id)
    c.should redirect_to(url(:login))
  end

  it "should raise a not found error if the tutorial cannot be found" do
    lambda do
      dispatch_to(Tutorials, :destroy, :id => 99854) do |c|
        c.stub!(:current_person).and_return(@p)
      end
    end.should raise_error(Merb::Controller::NotFound)
  end
  
  it "should ask the tutorial if it can be destroyed by the current person" do
    @s.should_receive(:destroyable_by?).and_return(true)
    Tutorial.should_receive(:first).and_return(@s)
    dispatch_to(Tutorials, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}
  end
  
  it "should raise an unauthorized error if it can't be destroyed by the current person" do
    @s.should_receive(:destroyable_by?).and_return(false)
    Tutorial.should_receive(:first).and_return(@s)
    lambda do
      dispatch_to(Tutorials, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}    
    end.should raise_error(Merb::Controller::Unauthorized)
  end
  
  it "should redirect to url(:tutorials) if the delete is successful" do
    @s.should_receive(:destroyable_by?).and_return(true)    
    Tutorial.should_receive(:first).and_return(@s)
    c = dispatch_to(Tutorials, :destroy, :id => @s.id){|c| c.stub!(:current_person).and_return @p}
    c.should redirect_to(url(:tutorials))
  end
  
  
end

describe Tutorials, "Publishable Actions" do
  
  before(:all){ @klass = Tutorials }
  
  it_should_behave_like "a controller that implements the publishable mixin"
    
  it "should implement the  publishable controller mixin" do
    Tutorials.should include(Merbunity::PublishableController::Setup)    
    Tutorials.publishable_klass.should == Tutorial
  end
end

