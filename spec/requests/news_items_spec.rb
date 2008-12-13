require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a news_item exists" do
  request(resource(:news_items), :method => "POST", 
    :params => { :news_item => { :id => nil, :title => "A Title", :description => "A description" }})
end

describe "resource(:news_items)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:news_items))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of news_items" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a news_item exists" do
    before(:each) do
      @response = request(resource(:news_items))
    end
    
    it "has a list of news_items" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      @response = request(resource(:news_items), :method => "POST", 
        :params => { :news_item => { :id => nil }})
    end
    
    it "redirects to resource(:news_items)" do
    end
    
  end
end

describe "resource(@news_item)" do 
  describe "a successful DELETE", :given => "a news_item exists" do
     before(:each) do
       puts NewsItem.first.inspect
       @response = request(resource(NewsItem.first), :method => "DELETE")
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
end

describe "resource(@news_item, :edit)", :given => "a news_item exists" do
  before(:each) do
    @response = request(resource(NewsItem.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@news_item)", :given => "a news_item exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(NewsItem.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @news_item = NewsItem.first
      @response = request(resource(@news_item), :method => "PUT", 
        :params => { :news_item => {:id => @news_item.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@news_item))
    end
  end
  
end

