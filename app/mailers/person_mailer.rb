class PersonMailer < Merb::MailController
  
  def signup_notification
    @person = params[:person]
    render_mail :text => :signup_notification
  end
  
  def activation_notification
    @person = params[:person]
    render_mail :text => :activation_notification
  end
  
  def forgot_password
    @person = params[:person]
    render_mail :text => :forgot_password
  end
  
  private
  def method_missing(*args)
    if @base_controller
      @base_controller.send(:method_missing, *args) 
    else
      super(*args)
    end
  end
    
end