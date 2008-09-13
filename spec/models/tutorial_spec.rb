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
      puts t.errors.inspect if t.errors.on(attr).size > 1
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
    pending("peding a resolution of the issue on the production server")
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
    tutorial.reload
    p.reload
    p.tutorials.should include(tutorial)
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