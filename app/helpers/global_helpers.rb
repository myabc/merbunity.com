require(File.dirname(__FILE__) / "publishable_helper")
require(File.dirname(__FILE__) / "permission_helper")
module Merb
  module GlobalHelpers
    include Merbunity::PublishableHelpers
    include Merbunity::PermissionHelpers
    include Merbunity::MenuHelper
    
    # def site_navigation_links
    #   nav ||= []
    #   nav << link_to("News",        url(:news))
    #   nav << link_to("Screencasts", url(:screencasts))
    #   nav << link_to("Tutorials",   url(:tutorials))
    #   nav << link_to("People",      url(:people))
    #   nav << link_to("Blogs",       url(:blogs))
    #   nav << link_to("Sites",       url(:sites))
    #   nav << link_to("Projects",    url(:projects))
    #   nav
    # end
    
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
      concat("<div class='box #{opts[:class]}'><h3>#{header}</h3><div class='box_content'", blk.binding)
      concat(yield, blk.binding)
      concat("</div></div>", blk.binding)
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
    
    def auto_discover_atom(feed_url)
      throw_content :auto_discover_atom,
          "<link href=\"#{feed_url}\" rel=\"alternate\" title=\"ATOM\" type=\"application/atom+xml\" />"
    end
    
    def atom_link(feed_url, opts = {})
      opts[:text] ||= "Subscribe"
      link_to( opts[:text], feed_url, :rel => "alternate",  :type => "application/atom+xml")
    end
    
    def paginate_links(url_name, page, opts = {})
      return "" if page.pager.number_of_pages < 2
      opts[:previous] ||= "Previous"
      opts[:next] ||= "Next"
      opts[:pages] ||= 5
      pager = page.pager
      
      out = "<ul class='page_links'>"
      
      out << "<li>#{link_to(opts[:previous], paginate_url(url_name, page, opts))}</li>" if page.prev?
      
      first_index = (page.number - opts[:pages] / 2)
      first_index = 1 if first_index < 1
      
      last_index = first_index + opts[:pages]
      last_index = pager.number_of_pages if pager.number_of_pages < last_index
      
      # Need to go back to the first one if we're skewed to the end of the range
      first_index = (last_index - opts[:pages]) != first_index  ? (last_index - opts[:pages]) : first_index
      first_index = 1 if first_index < 1
      
      (first_index..last_index).each do |i|
        if i == page.number
          out << "<li>#{i}</li>"
        else
          out << "<li>#{link_to(i, paginate_url(url_name, i, opts))}</li>"
        end
      end
      
      out << "<li>#{link_to(opts[:next], paginate_url(url_name, page.next.number, opts))}</li>" if page.next?
      out << "</ul>"
      out
    end
    
    
    
    private
    def paginate_url(name, page_number, opts)
      if opts[:object]
        url(name, :id => object.id, :page => page_number)
      else
        url(name, :page => page_number)
      end
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