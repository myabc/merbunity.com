require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
class People < Application
  provides :xml
  
  skip_before :login_required
  
  params_protected :person => [:publisher_since, :admin_since]
  
  def index 
    throw_content(:for_header, "People")
    render "Keep an eye out.  We're jazzing up the people information so this really feels like a community"
  end
  
  def new
    only_provides :html
    @person = Person.new(params[:person] || {})
    display @person
  end
  
  def create
    cookies.delete :auth_token
    
    @person = Person.new(params[:person])
    if @person.save
      redirect_back_or_default('/')
    else
      render :new
    end
  end
  
  def activate
    self.current_person = Person.find_activated_authenticated_model(params[:activation_code])
    if logged_in? && !current_person.active?
      current_person.activate
    end
    redirect_back_or_default('/')
  end
end