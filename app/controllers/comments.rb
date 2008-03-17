class Comments < Application
  
  before :login_required
  
  def create(id, klass, status, comment)
    klass = Object.const_get(klass)
    obj = klass[id]
    meth = (status == "pending" ? :pending_comments : :comments)
    @comment = Comment.new( comment )
    @comment.owner = current_person
    
    return redirect(request.referrer) unless @comment.save
    
    obj.send(meth) << @comment
    obj.save
    
    case content_type
    when :html
      redirect request.referer
    else
      display @comment, :show
    end
  end
  
end