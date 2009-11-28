class Articles < Application
  abstract!
  before :find_member,          :only     => [:show, :edit, :update, :delete, :destroy, :draft]
  before :ensure_authenticated, :exclude  => [:index, :show]
  before :is_owner,             :only     => [:edit, :update, :delete, :destroy]

  # This makes it so that for an inhertied controller, when rendering, first
  # it will look in that controllers views for the template, but, failing that
  # it will look in the articles view directory
  self.template_roots << [Merb.dir_for(:view), :article_template_location]

  # GET /news_items/:id/draft
  def draft(slug)
    if @article.has_draft?
      return render
    else
      if @article.published?
        redirect resource(@article)
      else
        raise InternalServerError, "Article is not published, but does not have a draft"
      end
    end
  end

  def show(slug)
    if @article.published?
      render
    else
      redirect resource(@article, :draft)
    end
  end

  def edit(slug)
    only_provides :html
    render
  end

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
