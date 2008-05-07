require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Tutorial do
  before do
    Tutorial.auto_migrate!
    @tutorial = Tutorial.new(valid_tutorial_hash)
  end

  it "should be setup valid" do
    @tutorial.save
    @tutorial.should be_valid
  end
  
  it "should have these attributes" do
    [:title, :body, :description, :created_at, :updated_at].each do |attr|
      @tutorial.attributes.keys.should include(attr)
    end
  end
  
  it "should require these attributes" do
    [ :title, :description, :body].each do |attr|
      t = Tutorial.new(valid_tutorial_hash.without(attr))
      t.save
      t.errors.on(attr).should_not be_nil
      t.errors.on(attr).should have(1).item
    end
  end
  
  it "should belong to an person" do
    @tutorial.should respond_to(:owner)    
  end

  it "should include the Merbunity::Publishable mixin" do
    Tutorial.should include(Merbunity::Publishable)
  end
  
  it "should include the Merbunity::Permissions::ProtectedModel mixin" do
    Tutorial.should include(Merbunity::Permissions::ProtectedModel)
  end
  
  it "should be invalid without an person" do
    tutorial = Tutorial.new(valid_tutorial_hash.without(:owner))
    tutorial.save
    tutorial.errors.should have(1).item
    tutorial.errors.on(:owner).should_not be_empty
  end
  
  it "should show up in the persons tutorials" do
    p = Person.create(valid_person_hash)
    p.activate
    p.make_publisher!
    tutorial = Tutorial.new(valid_tutorial_hash.with(:owner => p))
    tutorial.save
    tutorial.should_not be_new_record
    p.reload!
    p.tutorials.should include(tutorial)
  end
  
  it "should render textile of the body in display body" do
    tut = Tutorial.new(valid_tutorial_hash.with(:body => "h1. Heading"))
    tut.save
    tut.display_body.should have_tag(:h1){|t| t.should contain("Heading")}
  end

end

describe Tutorial, "Class Methods" do
  
  before(:each) do
    Tutorial.auto_migrate!
    Person.auto_migrate!
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
    1.upto(3) do
      c = Tutorial.new(valid_tutorial_hash)
      c.publish!(@pub)
      c.save
    end
    
    1.upto(5) do
      c = Tutorial.new(valid_tutorial_hash)
      c.save
      c.owner.publish(c)
    end
    
    1.upto(6) do
      c = Tutorial.new(valid_tutorial_hash)
      c.save
    end    
  end
  
  it "should get all pending tutorial" do
    d = Tutorial.pending
    d.should have(5).items
    d.all?{|s| s.pending?}
  end
  
  it "should get all published screencasts" do
    d = Tutorial.published
    d.should have(3).items
    d.all?{|s| s.published?}
  end
  
  it "should get all draft screencasts" do
    d = Tutorial.drafts
    d.should have(6).items   
    d.all?{|s| s.draft?}.should be_true
  end
  
end

describe Tutorial, "whistler" do
  before(:all) do
    DataMapper::Base.auto_migrate!
  end
  
  [:description, :title, :body].each do |prop|
    it "should white list on create" do
      Whistler.stub!(:white_list).and_return(true)
      Whistler.should_receive(:white_list).once.with("#{prop}").and_return("#{prop}")    
      c = Tutorial.new(valid_tutorial_hash.with(prop => "#{prop}"))
      c.save
    end
  
    it "should white list on save if the #{prop} has changed" do
      c = Tutorial.new(valid_tutorial_hash.with(prop => "not #{prop} here"))
      c.save
      Whistler.should_receive(:white_list).with("#{prop}").and_return("#{prop}")
      c.send("#{prop}=", "#{prop}")
      c.save    
    end
  
    it "should not white list the #{prop} attribute when it has not changed" do
      c = Tutorial.new(valid_tutorial_hash.with(prop => "#{prop}"))
      c.save
      Whistler.should_not_receive(:white_list)
      c.save    
    end
  end
  
end