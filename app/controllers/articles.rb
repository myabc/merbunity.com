class Articles < Application
  abstract!
  
  self.template_roots << [Merb.dir_for(:view), :article_template_location]
  
  private
  def article_template_location(action_name, format, controller_name)
    "articles/#{action_name}.#{format}"
  end
end