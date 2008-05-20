require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Welcome do
  before(:all) do
    day = Merb::Const::DAY
    @publisher = Person.create(valid_person_hash)
    @publisher.activate
    @publisher.make_publisher!
    
    @person = Person.create(valid_person_hash)
    @person.activate
    
    1.upto(12) do |i|
      s = Screencast.new(valid_screencast_hash.with(:owner => @publisher))
      s.save
      s.publish!(@publisher)
      s.created_at = Time.now - (day * i)
      s.published_on = Time.now - (day * i)
      s.save
      
      s = Tutorial.new(valid_tutorial_hash.with(:owner => @publisher))
      s.save
      s.publish!(@publisher)
      s.created_at = Time.now - (day * i)
      s.published_on = Time.now - (day * i)
      s.save
      
      n = NewsItem.create(valid_news_item_hash.with(:owner => @publisher))
      n.created_at = Time.now - (day * i)
      n.save
    end 
    
    @feed_result = [Screencast.published(:limit => 10), Tutorial.published(:limit => 10), NewsItem.all(:limit => 10)].flatten
    @feed_result = @feed_result.sort_by{|item| item.respond_to?(:published_on) ? item.published_on : item.created_at }.reverse
    @feed_result = @feed_result[0,10]
    
    @sc_result =  Screencast.published( :limit => 4)
    @ni_result =  NewsItem.all(   :limit => 4)
    @tut_result = Tutorial.published(   :limit => 4)
    
  end
  
  describe "index action" do
    def do_index(opts = {})
      @controller = dispatch_to(Welcome, :index, opts)
    end
    
    before(:each) do
      do_index
    end
    
    it "should be successful" do
      @controller.should be_successful
    end
    
    it "should have the latest 4 screencasts" do
      @controller.assigns(:screencasts).should == @sc_result      
    end
    
    it "should have the latest 4 News Items" do
      @controller.assigns(:news_items).should == @ni_result      
    end
    
    it "should have the latest 4 tutorials""" do
      @controller.assigns(:tutorials).should == @tut_result
    end
    
    it "should set @feed_items if a feed is requested" do
      do_index :format => :atom
      @controller.assigns(:feed_items).should == @feed_result
    end
    
  end
end