module Merb
  module GlobalHelpers
    
    def site_navigation_links
      nav ||= []
      nav << link_to("News",        url(:news))
      nav << link_to("Screencasts", url(:screencasts))
      nav << link_to("Tutorials",   url(:tutorials))
      nav << link_to("People",      url(:people))
      nav << link_to("Blogs",       url(:blogs))
      nav << link_to("Sites",       url(:sites))
      nav << link_to("Projects",    url(:projects))
      nav
    end
    
    # helpers defined here available to all views.  
    def page_title=(title)
      @_page_title = title
    end
    
    def page_title
      @_page_title
    end
    
    def for_publishers(obj = nil)
      if obj.nil? || obj.pending?
        yield if current_person.publisher? || current_person.admin?
      else
        yield if current_person.can_publish?(obj)
      end
    end
    
    def publish_button(url)
      out =<<-EOF
        <form method="post" action="#{url}"><input type='hidden' name='_method' value='PUT' /><button>Publish</button></form>
      EOF
    end
    
    def time_format(date, format = "%B %d, %Y")
      date.strftime(format)
    end
    
    # include a :class option to add more classes to the box
    def side_bar_box(header, opts = {}, &blk)
      concat("<div class='box #{opts[:class]}'><h3>#{header}</h3>", blk.binding)
      concat(yield, blk.binding)
      concat("</div>", blk.binding)
      # out =<<-EOF
      # <div class="box">
      #   <h3>#{header}</h3>
      #   #{yield}
      # </div>
      # EOF
      # out
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