class Passwords < Application
  before :login_required, :only => [:edit, :update]
  
  # NEW shows the html form to initiate the forgotten password request
  def new
    render
  end
  
  # Edit shows the reset password form for a currently logged in person
  def edit
    @person = current_person
    render
  end
  
  # Initiates a password reset for forgoten password
  def create(email)
    @person = Person.find_with_conditions(:email => email)
    raise NotFound if @person.nil?
    raise Unauthorized if logged_in? && @person != current_person
    flash[:notice] = "We've sent you a link to reset your password.  Keep an eye on your inbox."
    @person.forgot_password!
    redirect_back_or_default("/")
  end
  
  # Reset is the link given in the email with the reset password code attached
  # This action at best should be a 1 hit wonder link to log in the user, reset the code and 
  # redirect to edit.  If There's an error send them to the new action
  def show(id)
    @person = Person.find_with_conditions(:password_reset_key => id)
    if @person.nil?
      redirect_back_or_default "/"
    else
      self.current_person = @person
      redirect url(:edit_password_form)
    end
  end
  
  
  # Performs a password change for an existing user.  This is nice and big to ensure that we're only dealing with 
  # Changes to passwords.   Not arbitrary stuff.
  def update  
    @person = current_person
    if params[:person][:password].nil?
      flash[:error] = "You must enter a password"
      return render(:edit)
    end
    
    if !@person.has_forgotten_password?
      if @person != Person.authenticate(@person.login, params[:current_password])
        flash[:error] = "Your current password is incorrect"
        return render(:edit)
      end
    end
    
    @person.password = params[:person][:password]
    @person.password_confirmation = params[:person][:password_confirmation]
    
    if @person.save
      @person.clear_forgot_password!
      flash[:notice] = "Password Changed"
      redirect_back_or_default("/")
    else
      flash[:error] = "Password Not Changed"
      redirect url(:edit_password_form)
    end     
  end
  
end
