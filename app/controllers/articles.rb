class Articles < Application
  abstract!
  
  # This makes it so that for an inhertied controller, when rendering, first
  # it will look in that controllers views for the template, but, failing that
  # it will look in the articles view directory
  self.template_roots << [Merb.dir_for(:view), :article_template_location]
  
  private
  def article_template_location(action_name, format, controller_name)
    "articles/#{action_name}.#{format}"
  end
end