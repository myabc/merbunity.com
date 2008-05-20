class Welcome < Application
  
  def index
    @screencasts  = Screencast.published(  :limit => 4)
    @news_items   = NewsItem.all(          :limit => 4)
    @tutorials    = Tutorial.published(     :limit => 4)
    render
  end
  
end
