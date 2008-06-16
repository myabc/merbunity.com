require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do
  
  before(:each) do
    Comment.auto_migrate!
  end
  
  it "should have a body of text" do
    c = Comment.create(valid_comment_hash.with(:body => "My Body") )
    c.body.should == "My Body"
  end
  
  it "should have an owner who is a person in the system" do
    p = Person.create(valid_comment_hash)
    c = Comment.create(valid_comment_hash.with(:owner => p))
    c.owner.should == p
  end
  
  it "should have an error if there is no owner" do
    c = Comment.create(valid_comment_hash.except(:owner))
    c.errors.on(:owner).should_not be_nil
  end
  
  it "should have created at timestamps" do
    c = Comment.create(valid_comment_hash)
    c.created_at.should_not be_nil
    c.created_at.should be_a_kind_of(DateTime)
  end
end

describe Comment, "white listing" do
  
  before(:each) do
    Comment.auto_migrate!
  end
  
  it "should white list on create" do
    Whistler.should_receive(:white_list).with("body").and_return("body")    
    c = Comment.create(valid_comment_hash.with(:body => "body"))
  end
  
  it "should white list on save if the body has changed" do
    c = Comment.create(valid_comment_hash.with(:body => "not body here"))
    Whistler.should_receive(:white_list).with("body").and_return("body")
    c.body = "body"
    c.save    
  end
  
  it "should not white list the body attribute when it has not changed" do
    c = Comment.create(valid_comment_hash.with(:body => "body"))
    Whistler.should_not_receive(:white_list)
    c.save    
  end
    
  
end