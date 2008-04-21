class PersonMailer < Merb::MailController
  
  def signup_notification
    @person = params[:person]
    render_mail :text => :signup_notification
  end
  
  def activation_notification
    @person = params[:person]
    render_mail :text => :activation_notification
  end
  
  def request
    @base_controller.request if @base_controller
  end
end