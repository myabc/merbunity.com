class FeedbackMailer < Merb::MailController
  
  def feedback
    @person = params[:person]
    render_mail :text => :feedback
  end
  
end