class People < Application
  
  def show(slug)
    @user = User.first(:slug => slug)
    raise NotFound unless @user
    display @user
  end
  
  def new(user = {})
    only_provides :html
    redirect(resource(session.user)) and return if session.authenticated?
    @user = User.new(user)
    render
  end
  
  def create(user = {})
    @user = User.new(user)
    if @user.save
      redirect resource(@user), :message => {:notice => "Signup Successful"}
    else
      message[:error] = "There was a problem with your signup"
      self.status = Conflict.status
      render :new
    end
  end
  
end
