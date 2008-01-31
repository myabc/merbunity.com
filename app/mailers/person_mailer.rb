class PersonMailer < Merb::MailController
  
  def signup_notification
    @person = params[:person]
    render_mail
  end
  
  def activation_notification
    @person = params[:person]
    render_mail
  end
  
end