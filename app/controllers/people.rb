class People < Application
  provides :xml
  
  # skip_before :login_required
  
  # TODO: Create a show action for people
  
  def new(person = {})
    only_provides :html
    @person = Person.new(person)
    render @person
  end
  
  def create(person)
    cookies.delete :auth_token
    
    @person = Person.new(person)
    if @person.save
      redirect_back_or_default('/')
    else
      render :action => :new
    end
  end
  
  def activate(activation_code)
    self.current_person = Person.find_activated_authenticated_model(activation_code)
    if logged_in? && !current_person.active?
      current_person.activate
    end
    redirect_back_or_default('/')
  end
end