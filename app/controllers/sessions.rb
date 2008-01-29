require 'lib/authenticated_system_controller'
class Sessions < Application

  # skip_before :login_required
  
  def new
    render
  end

  def create(login = "", password = "")
    self.current_author = Author.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_author.remember_me
        cookies[:auth_token] = { :value => self.current_author.remember_token , :expires => self.current_author.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      render :action => "new"
    end
  end

  def destroy
    self.current_author.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
  
end