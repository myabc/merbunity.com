class Authors < Application
  provides :xml
  
  # skip_before :login_required
  
  def new(author = {})
    only_provides :html
    @author = Author.new(author)
    render @author
  end
  
  def create(author)
    cookies.delete :auth_token
    
    @author = Author.new(author)
    if @author.save
      redirect_back_or_default('/')
    else
      render :action => :new
    end
  end
  
  def activate(activation_code)
    self.current_author = Author.find_activated_authenticated_model(activation_code)
    if logged_in? && !current_author.active?
      current_author.activate
    end
    redirect_back_or_default('/')
  end
end