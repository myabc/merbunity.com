module Merb
  module GlobalHelpers
    
    def site_navigation_links
      nav ||= []
      nav << link_to("News", "#")
      nav << link_to("Screencasts", url(:screencasts))
      nav << link_to("Tutorials", "#")
      nav << link_to("People", "#")
      nav << link_to("Blogs", "#")
      nav << link_to("Sites", "#")
      nav << link_to("Projects", "#")
      nav
    end
    
    # helpers defined here available to all views.  
    def page_title=(title)
      @_page_title = title
    end
    
    def page_title
      @_page_title
    end
    
    def for_publishers
      yield if current_person.publisher? || current_person.admin?
    end
    
    def publish_button(url)
      out =<<-EOF
        <form method="post" action="#{url}"><input type='hidden' name='_method' value='PUT' /><button>Publish</button></form>
      EOF
    end
    
    def time_format(date, format = "%B %d, %Y")
      date.strftime(format)
    end
    
  end
end

class String
  # Truncates a string to the last previous end of word and applies a suffix.
  def truncate(required_length = 50, suffix = "...")
    if self.size > required_length
      # return self[0...required_length] << "..."
      if self.include?(" ")
        return self.slice(/\A(.){0,#{required_length}}\b/, 0).strip << suffix
      else
        return self.slice(0...required_length) << suffix
      end
    else
      return self
    end
  end
end