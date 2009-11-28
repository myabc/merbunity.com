class NewsItems < Articles


  # GET /news_items
  def index
    @articles = NewsItem.all
    render
  end

  # GET /news_items/drafts
  def drafts
    @articles = NewsItem.unpublished
    render :index
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
    @article.owner = session.user
    if params[:submit] && params[:submit] =~ /draft/i
      @draft = true
      res = @article.save_draft
    else
      @draft = false;
      res = @article.save
      @article.publish! if res
    end

    if res
      if @draft
        redirect resource(@article, :draft), :message => {:notice => "News Draft Created"}
      else
        redirect resource(@article), :message => {:notice => "News Reported"}
      end
    else
      message[:error] = "News Item not created"
      self.status = Conflict.status
      render :new
    end
  end

  # PUT /news_items/:id
  def update(slug, news_item)
    @article.attributes = news_item
    if params[:submit] && params[:submit] =~ /draft/i
      @draft = true
      result = @article.save_draft
    else
      @draft = false
      result = @article.save
      @article.publish! if result
    end

    if result
      if @draft
        redirect resource(@article, :draft), :message => {:notice => "Draft Updated Successfully"}
      else
        redirect resource(@article), :message => { :notice => "Updated Successfully"}
      end
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
    @article = NewsItem.first(:slug => params[:slug]) || (@draft = true; NewsItem.unpublished.first(:slug => params[:slug]))
    raise NotFound unless @article
    @article
  end
end
