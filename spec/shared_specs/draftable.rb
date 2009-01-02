require 'ruby-debug'
describe "a draftable resource", :shared => true do
  
  before(:each) do
    Object.class_eval do
      remove_const("Foo") if defined?(Foo)
    end
  end
  
  it "should have @klass defined" do
    @klass.should_not be_nil
  end
  
  describe "instance methods" do
    before(:each) do
      class Foo 
        include DataMapper::Resource
        
        property :id, Serial
        property :title, String
        property :body,  Text, :nullable => false
      
        is_draftable :title, :body
          
      end # Foo
      Foo.auto_migrate!
      Foo::Draft.auto_migrate!
    end
    
    it "should allow you to save_as_draft" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      foo.reload
      foo.draft.title.should == "foo title"    
      foo.draft.body.should == "foo body"
      foo.should_not be_a_new_record
    end
    
    it "should save the owning object when you save a draft" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.should be_a_new_record
      foo.save_draft
      foo.should_not be_a_new_record
    end
    
    it "should not include unpublished items in all" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      Foo.all.should_not include(foo)
    end
    
    it "should not get a given foo" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      foo.reload
      Foo.get(foo.id).should be_nil
    end
    
    it "should get a given unpublished foo" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      foo.reload
      Foo.unpublished.get(foo.id)
    end
    
    it "should get a list of all unpublished foos" do
      f1 = Foo.new(:title => "foo", :body => "foo")
      f2 = Foo.new(:title => "bar", :body => "bar")
      f1.save_draft; f2.save_draft
      Foo.all.should be_blank
      Foo.unpublished.all.should have(2).items
    end
    
    it "should allow you to draft declared Strings" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      foo.title.should == "foo title"
    end
    
    it "should allow you to draft declared Text" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save_draft
      foo.body.should == "foo body"
    end

    it "should return false when you ask if there is a draft and there is not" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save
      foo.draft.should be_nil
      foo.should_not have_draft
    end
    
    it "should not publish a draft until explicitly published" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save
      foo.should_not have_draft
      foo.save_draft
      foo.should have_draft
      foo.draft.title.should == "foo title"
      foo.draft.body.should  == "foo body"
    end
    
    it "should allow a draft to change the attributes without changing the main object" do
      foo = Foo.new(:title => "foo title", :body => "foo body")
      foo.save
      foo.save_draft
      foo.reload
      foo.body.should   == foo.draft.body
      foo.title.should  == foo.draft.title
      foo.draft.update_attributes(:title => "updated title", :body => "updated body")
      foo.reload
      foo.draft.title.should == "updated title"
      foo.draft.body.should  == "updated body"
      foo.title.should == "foo title"
      foo.body.should  == "foo body"
    end
    
    it "should push a draft to the main object when published and there is a draft present" do
      foo = Foo.new(:title => "foo", :body => "bar")
      foo.save_draft
      foo.reload
      foo.draft.update_attributes(:title => "updated title", :body => "updated body")
      foo.publish_draft!
      foo.reload
      foo.title.should == "updated title"
      foo.body.should  == "updated body"
      foo.published?.should be_true
      foo.should be_published
    end
    
    it "should raise an error when publishing a draft but no draft is present" do
      foo = Foo.new(:title => "foo", :body => "bar")
      foo.save
      foo.reload
      foo.should_not have_draft
      lambda do
        foo.publish_draft!
      end.should raise_error
    end
    
    it "should not push a draft to the main object when publishing and there is no draft present" do
      foo = Foo.new(:title => "foo", :body => "bar")
      foo.save
      foo.publish!
    end
    
    it "should clear the draft when plubished" do
      foo = Foo.new(:title => "foo", :body => "bar")
      foo.save_draft
      foo.publish_draft!
      f = Foo.get(foo.id)
      f.should be_published
      f.draft.should be_nil
    end
    
    it "should save the draft in the foo_drafts table" do
      Foo::Draft.storage_name.should == "foo_drafts"
    end
  end
  
  
end