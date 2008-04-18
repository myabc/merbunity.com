require(File.dirname(__FILE__) / "publishable_helper")
require(File.dirname(__FILE__) / "permission_helper")
module Merb
  module GlobalHelpers
    include Merbunity::PublishableHelpers
    include Merbunity::PermissionHelpers
    
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
    
    def time_format(date, format = "%B %d, %Y")
      date.strftime(format)
    end
    
    # include a :class option to add more classes to the box
    def side_bar_box(header, opts = {}, &blk)
      concat("<div class='box #{opts[:class]}'><h3>#{header}</h3>", blk.binding)
      concat(yield, blk.binding)
      concat("</div>", blk.binding)
    end
    
    def gravitar(person = current_person, opts = {})
      return "" unless logged_in?
      opts[:size] ||= 40
      opts[:rating] ||= "R"
      opts[:gravatar_id] = Digest::MD5.hexdigest(person.email.strip)      
      attrs = {}
      attrs[:src] = "http://www.gravatar.com/avatar.php?#{opts.to_params}"
      attrs[:class] = "gravitar"
      
      out = self_closing_tag(:img, attrs) unless person.nil?
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