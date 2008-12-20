class NewsItems < Articles
  
  # GET /news_items
  def index
    @articles = NewsItem.all
    render
  end

  # GET /news_items/new
  def new(news_item = {})
    only_provides :html
    @article = NewsItem.new(news_item)
    render
  end

  # POST /news_items
  def create(news_item)
    @article = NewsItem.new(news_item)
    if @article.save
      redirect resource(@article), :message => {:notice => "News Reported"}
    else
      message[:error] = "News Item not created"
      self.status = Conflict.status
      render :new 
    end
  end

  # PUT /news_items/:id
  def update(slug, news_item)    
    if @article.update_attributes(news_item)
      redirect resource(@article), :message => { :notice => "Updated Successfully"}
    else
      message[:error] = "News Item not updated"
      self.status = Conflict.status
      display @article, :edit
    end
  end

  # DELETE /news_items/:id
  def destroy(slug)
    @article.destroy
    redirect resource(:news_items)
  end
  
  private
  def find_member
    @article = NewsItem.first(:slug => params[:slug])
    raise NotFound unless @article
    @article
  end
end
