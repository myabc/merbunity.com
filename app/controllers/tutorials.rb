class Tutorials < Articles

  # GET /tutorials
  def index
    @articles = Tutorial.all
    render
  end

  # GET /tutorials/drafts
  def drafts
    @articles = NewsItem.unpublished
    render :index
  end


  # GET /tutorials/new
  def new(tutorial = {})
    only_provides :html
    @article = Tutorial.new(tutorial)
    render
  end

  # POST /news_items
  def create(tutorial)
    @article = Tutorial.new(tutorial)
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
        redirect resource(@article, :draft), :message => {:notice => "Tutorial Draft Created"}
      else
        redirect resource(@article), :message => {:notice => "Tutorial Published"}
      end
    else
      message[:error] = "Tutorial not created"
      self.status = Conflict.status
      render :new
    end
  end

  def update(slug, tutorial)
    @article.attributes = tutorial
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
      message[:error] = "Tutorial not updated"
      self.status = Conflict.status
      display @article, :edit
    end
  end

  # DELETE /tutorials/:id
  def destroy(slug)
    @article.destroy
    redirect resource(:tutorials)
  end

  private
  def find_member
    @article = Tutorial.first(:slug => params[:slug]) || (@draft = true; Tutorial.unpublished.first(:slug => params[:slug]))
    raise NotFound unless @article
    @article
  end
end
