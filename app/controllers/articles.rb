class Articles < Application
  abstract!
  before :find_member,          :only => [:show, :edit, :update, :delete, :destroy]
  before :ensure_authenticated, :exclude => [:index, :show]
  before :is_owner,             :only => [:edit, :update, :delete, :destroy]
  
  # This makes it so that for an inhertied controller, when rendering, first
  # it will look in that controllers views for the template, but, failing that
  # it will look in the articles view directory
  self.template_roots << [Merb.dir_for(:view), :article_template_location]
  
  # GET /news_items/:id
  def show(slug)
    render
  end
  
  # GET /news_items/:id/edit
  def edit(slug)
    only_provides :html
    render
  end

  # GET /news_items/:id/delete
  def delete
    render
  end

  private
  def article_template_location(action_name, format, controller_name)
    "articles/#{action_name}.#{format}"
  end
  
  def is_owner
    raise Forbidden unless @article.owner == session.user
  end
  
end