class Welcome < Application
  
  def index
    provides :atom
    case content_type
    when :atom
      @feed_items = [Screencast.published(:limit => 10), Tutorial.published(:limit => 10), NewsItem.all(:limit => 10)].flatten.compact
      @feed_items = @feed_items.sort_by{|item| item.respond_to?(:published_on) ? item.published_on : item.created_at }.reverse
      @feed_items = @feed_items[0,10]
      puts @feed_items.map{|i| i.title}.inspect
    else
      @screencasts  = Screencast.published(  :limit => 4)
      @news_items   = NewsItem.all(          :limit => 4)
      @tutorials    = Tutorial.published(     :limit => 4)
    end

    render
  end
  
end
