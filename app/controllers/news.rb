class News < Application
  # provides :xml, :yaml, :js
  before :find_news_item, :only => [:show]
  before :login_required, :only => [:new, :create, :edit, :update]
  before :non_publisher_help
  
  params_protected :news_item => [:create_at, :updated_at, :owner, :owner_id]
  
  def index(page = 0)
    provides :atom
    @pager = Paginator.new(NewsItem.count, 10) do |offset, per_page|
                  NewsItem.all(:limit => per_page, :offset => offset, :order => [:created_at.desc])
             end
    @page = @pager.page(page)
    @news_items = @page.items
    
    display @news_items
  end
  # 
  def show
    display @news_story
  end
  
  def new(news_item = {})
    only_provides :html
    @news_item = NewsItem.new(news_item)
    display @news_item
  end
  
  def create(news_item)
    raise Unauthorized unless current_person.publisher? || current_person.admin?
    @news_item = NewsItem.new(news_item)
    @news_item.owner = current_person
    if @news_item.save
      flash[:notice] = "Published your News"
      redirect url(:news, @news_item)
    else
      flash[:error] = "There were issues"
      render :new
    end
  end
  
  def edit(id)
    @news_item = NewsItem[id]
    raise Unauthorized unless @news_item.owner == current_person || current_person.admin?
    render 
  end
  
  def update(id, news_item)
    @news_item = NewsItem[id]
    raise NotFound if @news_item.nil?
    raise Unauthorized unless @news_item.owner == current_person || current_person.admin?
    if @news_item.update_attributes(news_item)
      flash[:notice] = "Your news has been updated"
      redirect url(:news, @news_item)
    else
      flash[:error] = "Your news has not been updated"
      edit id
    end
  end
      
  def destroy(id)
    @news_item = NewsItem[id]
    raise NotFound if @news_item.nil?
    raise Unauthorized unless @news_item.owner == current_person || current_person.admin?
    @news_item.destroy!
    flash[:notice] = "News Item Deleted"
    redirect "/"
  end
  
  private
  def find_news_item
    @news_item = NewsItem.get(params[:id])
    raise NotFound unless @news_item
    @news_item
  end
  
  def non_publisher_help
    return true if !logged_in? || current_person.publisher?
    partial(:non_publisher_help, :format => :html)
  end
  
end
