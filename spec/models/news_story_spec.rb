require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe NewsStory do
  
  before(:all) do
    DataMapper::Base.auto_migrate!
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
    
    @person = Person.new(valid_person_hash)
    @person.save
    @person.activate
    
    @admin = Person.new(valid_person_hash)
    @admin.save
    @admin.activate
    @admin.make_admin!
  end
  
  it "should be a valid news story" do
    ns = NewsStory.new(valid_news_story_hash)
    ns.save
    ns.errors.should be_empty
  end
  
  it "should setup the spec values" do
    @person.should_not be_admin
    @person.should_not be_publisher
    
    @publisher.should be_publisher
    @publisher.should_not be_admin
    
    @admin.should be_admin
  end
  
  it "should require a title" do
    ns = NewsStory.new(valid_news_story_hash.without(:title))
    ns.save
    ns.errors.on(:title).should_not be_nil
    ns.errors.on(:title).should have(1).items
  end
  
  it "should require an owner" do
    ns = NewsStory.new(valid_news_story_hash.without(:owner))
    ns.save
    ns.errors.on(:owner).should_not be_nil
  end
  
  it "should require a body" do
    ns = NewsStory.new(valid_news_story_hash.without(:body))
    ns.save
    ns.errors.on(:body).should_not be_nil
    ns.errors.on(:body).should have(1).item
  end
  
  it "should not be valid if the person is not a publisher or admin" do
    ns = NewsStory.new(valid_news_story_hash.with(:owner => @person))
    ns.save
    ns.errors.on(:owner).should_not be_nil
    ns.errors.on(:owner).should have(1).item
  end
  
end