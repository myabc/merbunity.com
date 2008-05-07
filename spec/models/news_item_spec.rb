require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe NewsItem do
  
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
    ns = NewsItem.new(valid_news_item_hash)
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
    ns = NewsItem.new(valid_news_item_hash.without(:title))
    ns.save
    ns.errors.on(:title).should_not be_nil
    ns.errors.on(:title).should have(1).items
  end
  
  it "should require an owner" do
    ns = NewsItem.new(valid_news_item_hash.without(:owner))
    ns.save
    ns.errors.on(:owner).should_not be_nil
  end
  
  it "should require a description" do
    ns = NewsItem.new(valid_news_item_hash.without(:description))
    ns.save
    ns.errors.on(:description).should_not be_nil
    ns.errors.on(:description).should have(1).item
  end
  
  it "should render the body via display_body with textile" do
    ns = NewsItem.new(valid_news_item_hash.with(:body => "h2. Header"))    
    ns.display_body.should have_tag(:h2){|t| t.should contain("Header")}
  end
  
  it "should not be valid if the person is not a publisher or admin" do
    ns = NewsItem.new(valid_news_item_hash.with(:owner => @person))
    ns.save
    ns.errors.on(:owner).should_not be_nil
    ns.errors.on(:owner).should have(1).item
  end
  
  it "should be valid if the person is a publisher" do
    ns = NewsItem.new(valid_news_item_hash.with(:owner => @publisher))
    ns.save
    ns.should_not be_new_record
  end
  
  it "should be valid if the person is an admin" do
    ns = NewsItem.new(valid_news_item_hash.with(:owner => @admin))
    ns.save
    ns.should_not be_new_record
  end
  
  it "should be publishable by an admin or a publisher" do
    ns = NewsItem.new(valid_news_item_hash)
    ns.save
    [@publisher, @admin].each do |u|
      ns.publishable_by?(u).should be_true
    end
  end
  
  it "should not be publishable by a non admin publisher" do
    ns = NewsItem.new(valid_news_item_hash)
    ns.save
    [@person, :false, nil].each do |u|
      ns.publishable_by?(u).should be_false
    end
  end
  
  it "should only be destroyable_by? admin" do
    ns = NewsItem.new(valid_news_item_hash)
    ns.save
    ns.destroyable_by?(@admin).should be_true
    ns.destroyable_by?(@publisher).should be_false
    ns.destroyable_by?(@person).should be_false
    ns.destroyable_by?(nil).should be_false
    ns.destroyable_by?(:false).should be_false
  end
  
  it "should be viewable by anyone" do
    ns = NewsItem.new(valid_news_item_hash)
    ns.save
    [@admin, @publisher, @person, nil, :false].each do |u|
      ns.viewable_by?(u)
    end
  end
  
  it "should only be editable by and admin" do
    ns = NewsItem.new(valid_news_item_hash)
    ns.save
    ns.editable_by?(@admin).should be_true
    [@publisher, @person, nil, :false].each do |u|
      ns.editable_by?(u).should be_false
    end
  end
  
  it "should be editable by the owner" do
    ns = NewsItem.new(valid_news_item_hash.with(:owner => @publisher))
    ns.save
    ns.should_not be_new_record
    ns.editable_by?(@publisher).should be_true
    [@person, nil,:false].each do |u|
      ns.editable_by?(u).should be_false
    end
  end
  
  it "should show up in the persons news_items" do
    ns = NewsItem.new(valid_news_item_hash.with(:owner => @publisher))
    ns.save
    ns.should_not be_new_record
    @publisher.reload!
    @publisher.news_items.should include(ns)
  end

end