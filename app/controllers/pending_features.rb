class PendingFeatures < Application
  
  before :set_page_header
  
  def tutorials
    render "<div class='item'>Keep an eye out. There's going to be some great tutorials soon</div>"
  end
  
  def blogs
    render "<div class='item'>Keep and eye out.  We'll be adding a blog register shortly</div>"
  end
  
  def sites
    render "<div class='item'>Want to put your merb site up to showcase.  This section will be done shortly.</div>"
  end
  
  def projects
    render "<div class='item'>Show off your projects, coming soon</div>"
  end
  
  def terms_of_service
    render
  end
  
  def faq
    render
  end
  
  def about
    render
  end
  
  protected
  def set_page_header
    throw_content(:for_header, self.action_name.capitalize)
  end
  
end