class Feedback < Application
  
  def new
    only_provides :html
    render
  end
  
  def create
    FeedbackMailer.dispatch_and_deliver(:feedback, 
      {
        :from     => "feedback@merbunity.com",
        :to       => "dneighman@gmail.com",
        :subject  => "[Merbunity.com] Feedback"
      },
      (logged_in? ? {:person => current_person} : {})
    )
    flash[:notice] = "Thankyou. We value your feedback :)"
    redirect "/"
  end
  
end
