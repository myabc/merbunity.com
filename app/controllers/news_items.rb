class NewsItems < Articles
  
  # GET /news_items
  def index
    @news_items = NewsItem.all
    render
  end

  # GET /news_items/:id
  def show(id)
    @news_item = NewsItem.get(id) 
    render
  end

  # GET /news_items/new
  def new
    @news_item = NewsItem.new
    render
  end

  # GET /news_items/:id/edit
  def edit(id)
    @news_item = NewsItem.get(id) 
    render
  end

  # GET /news_items/:id/delete
  def delete
    render
  end

  # POST /news_items
  def create(news_item)
    @news_item = NewsItem.new(news_item)
    if @news_item.save
      redirect resource(@news_item), :message => {:notice => "News Reported"}
    else
      message[:error] = "News Item not created"
      self.status = Conflict.status
      render :new 
    end
  end

  # PUT /news_items/:id
  def update(id, news_item)
    @news_item = NewsItem.get(id)
    raise NotFound unless @news_item 
    if @news_item.update_attributes(news_item)
      redirect resource(@news_item)
    else
      display @news_item, :edit
    end
  end

  # DELETE /news_items/:id
  def destroy
    render
  end
end
