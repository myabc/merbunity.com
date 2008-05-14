class Feedback < Application
  
  def new
    only_provides :html
    render
  end
  
  def create
    params[:person] = current_person if logged_in?
    FeedbackMailer.dispatch_and_deliver(:feedback, 
      {
        :from     => "feedback@merbunity.com",
        :to       => "dneighman@gmail.com",
        :subject  => "[Merbunity.com] Feedback"
      },
      params
    )
    puts Merb::Mailer.deliveries.last.inspect if Merb.env?(:development)
    flash[:notice] = "Thankyou. We value your feedback :)"
    redirect "/"
  end
  
end
