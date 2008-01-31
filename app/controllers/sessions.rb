require 'lib/authenticated_system_controller'
class Sessions < Application

  # skip_before :login_required
  
  def new
    render
  end

  def create(login = "", password = "")
    self.current_person = Person.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_person.remember_me
        cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      render :action => "new"
    end
  end

  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
  
end