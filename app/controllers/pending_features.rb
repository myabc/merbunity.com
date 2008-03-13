class PendingFeatures < Merb::Controller
  
  before :set_page_header
  
  def news
    render "Keep an eye out.  The news feature isn't far away"
  end
  
  def tutorials
    render "Keep an eye out. There's going to be some great tutorials soon"
  end
  
  def blogs
    render "Keep and eye out.  We'll be adding a blog register shortly"
  end
  
  def sites
    render "Want to put your merb site up to showcase.  This section will be done shortly."
  end
  
  def projects
    render "Show off your projects, coming soon"
  end
  
  protected
  def set_page_header
    throw_content(:for_header, self.action_name.capitalize)
  end
  
end