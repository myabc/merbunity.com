class Exceptions < Application

  # handle NotFound exceptions (404)
  def not_found
    render :format => :html
  end

  def unauthorized
    flash[:error] = "You are not authorized to perform this action"
    redirect url(:login)
  end

  # handle NotAcceptable exceptions (406)
  def not_acceptable
    render :format => :html
  end

end
