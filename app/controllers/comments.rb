class Comments < Application
  
  before :login_required
  
  after :send_notification
  
  def create(id, klass, comment)
    klass = Object.const_get(klass)
    @obj = klass[id]
    meth = @obj.published? ? :comments : :pending_comments
    @comment = Comment.new( comment )
    @comment.owner = current_person
    
    return redirect(request.referrer) unless @comment.save
    
    @obj.send(meth) << @comment
    @obj.save
    flash[:notice] = "Your comment has joined the discussion" unless @obj.new_record?
    case content_type
    when :html
      redirect request.referer
    else
      display @comment, :show
    end
  end
  
  
  private
  def send_notification
    subject = "#{current_person.login} has commented on your #{@obj.class}"
    subject <<" - " << @obj.title if @obj.respond_to?(:title)
    CommentMailer.dispatch_and_deliver(:comment_notification, {
                                                                :to => @obj.owner.email,
                                                                :from => "info@merbunity.com",
                                                                :subject => "#{current_person.login}",
                                                                :replyto => "no-reply@merbunity.com"
                                                              },
                                                              :obj => @obj,
                                                              :comment => @comment,
                                                              :current_person => current_person,
                                                              :url => absolute_url(named_route_for(@obj), @obj))
  end
  
  
end