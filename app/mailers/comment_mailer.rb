class CommentMailer < Merb::MailController
  include Merb::GlobalHelpers
  def comment_notification
    @object = params[:object]
    @current_person = params[:current_person]
    @comment = params[:comment]
    @url = params[:url]
    render_mail :text => :comment_notification
  end

end
