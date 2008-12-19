class Tutorials < Articles
  
  
  # GET /tutorials
  def index
    @articles = Tutorial.all
    render
  end

  # GET /tutorials/new
  def new(tutorial = {})
    only_provides :html
    @article = Tutorial.new(tutorial)
    render
  end
  
  # POST /tutorials
  def create(tutorial)
    @article = Tutorial.new(tutorial)
    if @article.save
      redirect resource(@article), :message => {:notice => "Tutorial Created"}
    else
      message[:error] = "Tutorial not created"
      self.status = Conflict.status
      render :new 
    end
  end

  # PUT /tutorials/:id
  def update(slug, tutorial)
    if @article.update_attributes(tutorial)
      redirect resource(@article), :message => { :notice => "Updated Successfully"}
    else
      message[:error] = "News Item not updated"
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
    @article = Tutorial.first(:slug => params[:slug])
    raise NotFound unless @article
    @article
  end
end
