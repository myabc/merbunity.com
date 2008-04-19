require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "News Controller Setup", :shared => true do
  before(:all) do
    DataMapper::Base.auto_migrate!
    
    @person = Person.new(valid_person_hash)
    @person.save
    @person.activate
    
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
    
    @admin = Person.new(valid_person_hash)
    @admin.save
    @admin.activate
    @admin.make_admin!
    
    1.upto(15) do
      n = NewsItem.new(valid_news_item_hash)
    end
  end
  
  before(:each) do
    @ns = NewsItem.new(valid_news_item_hash.with(:owner => @publisher))
    @ns.save
  end
  
  after(:each) do
    @ns.destroy!
  end
end

describe News, "index action"  do
  it_should_behave_like "News Controller Setup"
  
  def latest_10
    @latest_10 ||= NewsItem.all(:order => "created_at DESC", :limit => 10)
  end
  
  it "should show the 10 latest news items with no-one logged in" do
    controller = dispatch_to(News, :index)
    controller.assigns(:news_items).should == latest_10
    controller.should be_successful
  end
  
  it "should show the 10 latest news items with the publisher logged in" do
    controller = dispatch_to(News, :index){|c| c.stub!(:current_person).and_return(@publisher)}
    controller.assigns(:news_items).should == latest_10
    controller.should be_successful
  end
end

describe News, "show action" do
  it_should_behave_like "News Controller Setup"
  
  it "should show the specified news item with no-one logged in" do
    controller = dispatch_to(News, :show, :id => @ns.id)
    controller.assigns(:news_item).should == @ns
    controller.should be_successful
  end
  
  it "should show the specified news item with a publisher logged in" do
    controller = dispatch_to(News, :show, :id => @ns.id){|c| c.stub!(:current_person).and_return(@publisher)}
    controller.assigns(:news_item).should == @ns
    controller.should be_successful
  end
  
  it "should raise a not found error if the news item is not there" do
    NewsItem.first(999).should be_nil
    lambda do
      dispatch_to(News, :show, :id => 999)
    end.should raise_error(Merb::ControllerExceptions::NotFound)
  end
end

describe News, "New action" do
  it_should_behave_like "News Controller Setup"
  
  # it "should render the new action if you are a publisher or admin" do
  #   [@admin, @publisher].each do |u|
  #     c = dispatch_to(News, :new){|k| k.stub!(:current_person).and_return(u)}
  #     c.should be_successful
  #   end
  # end
  
  it "should redirect to login if not logged in" do
    c = dispatch_to(News, :new)
    c.should redirect_to(url(:login))
  end
end

describe News, "Create action" do
  it_should_behave_like "News Controller Setup"
  
  def news_item_submission
    {
      :title => "My Title",
      :description => "Description",
      :body => "h2. This is the body"
    }
  end
  
  it "should redirect to login if not logged in" do
    c = dispatch_to(News, :create, :news_item => news_item_submission)
    c.should redirect_to(url(:login))
  end
  
  it "should create the news item if logged in as a publisher" do
    lambda do
      @c = dispatch_to(News, :create, :news_item => valid_news_item_hash.without(:owner)) do |k|
        k.stub!(:current_person).and_return(@publisher)
      end
      @c.assigns(:news_item).owner.should == @publisher
    end.should change(NewsItem, :count).by(1)
  end

  it "should not create the news if the person is not a publisher" do
    person = Person.new(valid_person_hash)
    person.save
    person.activate
    lambda do
      c = dispatch_to(News, :create, :news_item => valid_news_item_hash.without(:owner)) do |k|
        k.stub!(:current_person).and_return(person)
      end
    end.should raise_error(Merb::ControllerExceptions::Unauthorized)
  end
  
  it "should render new if the news_item doesn't save" do
    news_mock = mock('news_item', :null_object => true)
    news_mock.should_receive(:save).and_return(false)
    NewsItem.should_receive(:new).and_return(news_mock)
    c = dispatch_to(News, :create, :news_item => valid_news_item_hash.without(:owner)) do |k|
      k.stub!(:current_person).and_return(@publisher)
    end
    c.should be_successful
    c.flash[:error].should_not be_blank
  end
  
  
end