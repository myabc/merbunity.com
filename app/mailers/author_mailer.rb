class AuthorMailer < Merb::MailController
  
  def signup_notification
    @author = params[:author]
    render_mail
  end
  
  def activation_notification
    @author = params[:author]
    render_mail
  end
  
end