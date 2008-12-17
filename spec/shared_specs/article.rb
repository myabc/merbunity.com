describe "an article", :shared => true do
  
  before(:each) do
    @klass.all.destroy!
    @article = @klass.make
  end
  
  it "should have a title" do
    @article.title.should_not be_blank
  end
  
  it "should be invalid without a title" do
    article = @klass.make_unsaved(:title => nil)
    article.should_not be_valid
    article.errors.on(:title).should_not be_blank
  end
  
  it "should be invalid with a duplicate title" do
    a1 = @klass.make_unsaved(:title => "foo")
    a2 = @klass.make_unsaved(:title => "foo")
    a1.save; a2.save
    a1.should_not be_a_new_record
    a2.should be_a_new_record
    a2.errors.on(:title).should_not be_blank
  end
  
  it "should have a slug" do
    article = @klass.make(:title => "foo bar")
    article.slug.should == "foo-bar"
  end
  
  it "should be invalid with a duplicate slug" do
    a1 = @klass.make_unsaved(:title => "foo bar")
    a2 = @klass.make_unsaved(:title => "foo-bar")
    a1.save; a2.save
    a1.should_not be_a_new_record
    a2.should be_a_new_record
    a2.errors.on(:slug).should_not be_blank
  end
  
  it "should not allow you to set the slug manually" do
    article = @klass.make(:title => "foo")
    lambda do
      article.slug = "foo bar"
    end.should raise_error(NoMethodError)
  end
  
  it "should have a description" do
    @article.description.should be_a_kind_of(String)
  end
  
  it "should be invalid without a description" do
    a = @klass.make_unsaved(:description => nil)
    a.should_not be_valid
    a.errors.on(:description).should_not be_blank
  end
  
  it "should have a body" do
    @article.body.should be_a_kind_of(String)
  end
  
  it "should have a created_at" do
    @article.created_at.should be_a_kind_of(DateTime)
  end
  
  it "should have a created_on" do
    @article.created_on.should be_a_kind_of(Date)
  end
  
  it "should have an updated_at" do
    @article.updated_at.should be_a_kind_of(DateTime)
  end
  
  it "shoudl have an updated_on" do
    @article.updated_on.should be_a_kind_of(Date)
  end
  
end