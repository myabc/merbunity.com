require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a news_item exists" do
  NewsItem.make
end

describe "a news item form", :shared => true do
  it "should have a title field" do
    xpath = "//form//input[@name='news_item[title]']"
    @response.should have_xpath(xpath)
  end
  
  it "should have a description field" do
    xpath = "//form//textarea[@name='news_item[description]']"
    @response.should have_xpath(xpath)
  end
  
  it "should have a body field" do
    xpath = "//form//textarea[@name='news_item[body]']"
    @response.should have_xpath(xpath)
  end
  
  it "should have a submit button" do
    xpath = "//form//input[@type='submit']"
    @response.should have_xpath(xpath)
  end
end

describe "resource(:news_items)" do
  describe "GET with no news items" do
    before(:each) do
      NewsItem.all.destroy!
      @response = request(resource(:news_items))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end
  
    it "contains a list of news_items" do
      @response.should have_xpath("//*[@class='articles']")
    end
  end
  
  describe "GET", :given => "a news_item exists" do
    before(:all) do
      (1..5).each{ NewsItem.make }
    end
    
    before(:each) do
      @response = request(resource(:news_items))
    end
    
    it "has a list of news_items" do
      @response.should have_xpath("//ul[@class='articles']/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      NewsItem.all.destroy!
    end
    
    def default_params(params={})
      {
        :title        => Sham.title,
        :description  => Sham.paragraph,
        :body         => Sham.paragraphs
      }.merge(params)
    end
    
    def fill_out_news_item_form!(params = {})
      params = default_params(params)
      visit resource(:news_items, :new)
      fill_in "Title",        :with => params[:title]
      fill_in "Description",  :with => params[:description]
      fill_in "Body",         :with => params[:body]
      response = click_button("Save")
    end
    
    it "create a new post" do
      fill_out_news_item_form!      
      NewsItem.all.should have(1).item
    end
    
    it "should redirect to the new news item" do
      response = request(resource(:news_items), :method => "POST", :params => {:news_item => default_params})
      response.should redirect_to(resource(NewsItem.first))
    end
    
    it "should render the new form when there is a problem with the post" do
      response = request(resource(:news_items), :method => "POST", :params => {:news_item => {:body => "foo"}})
      response.status.should == Merb::Controller::Conflict.status
      response.should have_xpath("//form[@action=\"#{resource(:news_items)}\"]")
    end
  end
end

describe "resource(@news_item)" do 
  describe "a successful DELETE", :given => "a news_item exists" do
    before(:each) do
      @response = request(resource(NewsItem.first), :method => "DELETE")
    end
    
    it "should delete a news item" do
      NewsItem.count.should == 0
      NewsItem.make
      lambda do
        response = request(resource(NewsItem.first), :method => "DELETE")
      end.should change(NewsItem, :count).by(-1)
    end
    
     it "should redirect to the index action" do
       @response.should redirect_to(resource(:news_items))
     end

   end
end

describe "resource(:news_items, :new)" do
  before(:each) do
    @response = request(resource(:news_items, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
  
  it "should render a news item form" do
    xpath = "//form[@action=\"#{resource(:news_items)}\"][@method='post'][not(input[@name='_method'])]"
    @response.should have_xpath(xpath)
  end
  
  it_should_behave_like "a news item form"
end

describe "resource(@news_item, :edit)", :given => "a news_item exists" do
  before(:each) do
    @news_item = NewsItem.first
    @response = request(resource(@news_item, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
  
  it "should render a news item edit form" do
    xpath = "//form[@action=\"#{resource(@news_item)}\"][@method='post'][input[@name='_method'][@value='put']]"
    @response.should have_xpath(xpath)
  end
  
  it_should_behave_like "a news item form"
  
  it "should have the title of the news item on the page" do
    xpath = "//*[contains(text(), '#{@news_item.title}')]"
  end
  
end

describe "resource(@news_item)" do
  
  describe "GET" do
    before(:each) do
      @ni = NewsItem.first
      @response = request(resource(@ni))
    end

    it "responds successfully" do
      @response.should be_successful
    end
    
    it "should have the title of the news item on the page" do
      xpath = "//h1[contains(text(), '#{@ni.title}')]"
      @response.should have_xpath(xpath)
    end
    
    it "should have the description of the news item on the page" do
      xpath = "//*[@class='description'][contains(text(), '#{@ni.description}')]"
      @response.should have_xpath(xpath)
    end
    
    it "should have the body of the news item on the page" do
      @ni.body.should_not be_blank
      xpath = "//*[@class='content'][contains(text(), '#{@ni.body}')]"
      @response.should have_xpath(xpath)
    end
    
    it "should be missing if a news item is requested that does not exist" do
      response = request(url(:news_item, :slug => "foo"))
      response.should be_missing
    end
        
  end

  describe "PUT" do
    before(:each) do
      @news_item = NewsItem.first
      @response = request(resource(@news_item), :method => "PUT", 
        :params => { :news_item => {:title => "fooooo"} })
    end
    
    describe "failed update" do
      before(:each) do
        @n2 = NewsItem.make(:title => "Not Foo")
        @failed_response = request(resource(@n2), :method => "PUT", :params => { :news_item => {
          :title => "fooooo"
        }})
      end
      
      it "should render the edit form on a failure" do
        xpath = "//form[@action=\"#{resource(@n2)}\"][//input[@name='_method'][@value='put']]"
        @failed_response.should have_xpath(xpath)
      end
      
      it "should not update the title of the news item" do
        @n2.reload
        @n2.title.should_not == "fooooo"
      end
      
      it "should return a conflict" do
        @failed_response.status.should == Merb::Controller::Conflict.status
      end
    end
    
    it "should update the news items title" do
      @news_item.reload      
      @news_item.title.should == "fooooo"
    end
    
    it "redirect to the article show action when successful" do
      @response.should redirect_to(resource(@news_item))
    end
  end

end

