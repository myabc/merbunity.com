class Welcome < Application
  
  def index
    provides :atom
    case content_type
    when :atom
      @feed_items = [Screencast.published(:limit => 10), Tutorial.published(:limit => 10), NewsItem.all(:limit => 10, :order => "created_at DESC")].flatten.compact
      @feed_items = @feed_items.sort_by{|item| item.respond_to?(:published_on) ? item.published_on : item.created_at }.reverse
      @feed_items = @feed_items[0,10]
    else
      @news_items   = NewsItem.all( :limit => 3, :order => "created_at DESC")
      @recent_items = [Screencast.published(:limit => 5), Tutorial.published(:limit => 5)].flatten.compact
      @recent_items = @recent_items.sort_by{|i| i.published_on}.reverse
      @recent_items = @recent_items[0,5]
    end

    render
  end
  
end
