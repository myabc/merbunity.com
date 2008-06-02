describe "a model with comments", :shared => true do

  it "should have and belong to many comments" do
    DataMapper.auto_migrate!
    p = Person.create(valid_person_hash)
    m = @klass.create(:owner => p)
    c = Comment.create(valid_comment_hash)
    m.comments << c
    m.should have(1).comments
    m.save
    
    z = @klass[m.id]
    z.should have(1).comments
  end
end

describe "a model with pending comments", :shared => true do
  it "should have and belong to many pending comments" do
    DataMapper.auto_migrate!
    Comment.all.size.should == 0
    Person.all.size.should == 0
    @klass.all.size.should == 0
    
    p = Person.create(valid_person_hash)
    
    m = @klass.create(:owner => p)
    c = Comment.create(valid_comment_hash)
    
    m.pending_comments << c
    m.pending_comments.size.should == 1
    m.save!
    
    m.reload!
    m.should have(1).pending_comments
    
    z = @klass[m.id]
    z.should have(1).pending_comments
  end  
  
  it "should not mix pending and normal comments" do
    m = @klass.create(:owner => @person)
    c = Comment.create(valid_comment_hash.with(:owner => @person))
    pc = Comment.create(valid_comment_hash.with(:owner => @person))
    m.comments << c
    m.pending_comments << pc
    m.save
    
    k = @klass[m.id]
    k.comments.should include(c)
    k.pending_comments.should include(pc)
  
    k.comments.should_not include(pc)
    k.pending_comments.should_not include(c)
  end
end