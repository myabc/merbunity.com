require(File.dirname(__FILE__) / "publishable_helper")
require(File.dirname(__FILE__) / "permission_helper")
module Merb
  module GlobalHelpers
    include Merbunity::PublishableHelpers
    include Merbunity::PermissionHelpers
    include Merbunity::MenuHelper
    
    def nice_class_name(klass, opts = {})
      name = klass.name.snake_case.gsub("_", " ").split(" ").map{|i| i.capitalize}
      name[-1] = name.last.pluralize if opts[:plural]
      name.join " "
    end
    
    # Returns a named route for an object.  This is because some objects may be ambiguous as to where they are displayed
    def named_route_for(obj)
      case obj
      when NewsItem
        :news
      when Screencast
        :screencast
      when Tutorial
        :tutorial
      end
    end
    
    def collection_named_route_for(obj)
      case obj
      when NewsItem
        :news
      when Screencast
        :screencasts
      when Tutorial
        :tutorials
      end
    end
    
    # helpers defined here available to all views.  
    def page_title(title = nil)
      @_page_title ||= title
    end
    
    # def page_title
    #   @_page_title
    # end
    
    def time_format(date, format = "%B %d, %Y")
      date.strftime(format)
    end
    
    # include a :class option to add more classes to the box
    def side_bar_box(header, opts = {}, &blk)
      haml_tag(:div, :class => opts[:class]) do
        haml_tag(:h3, header)
        haml_tag(:div, capture_haml(&blk), :class => "box_content")
      end.to_s
    end
    
    def help_box(header, opts = {}, &blk)
      opts.add_html_class!(:help)
      throw_content(:for_side, side_bar_box(header, opts, &blk))
    end
    
    def gravatar(person = current_person, opts = {})
      opts[:size] ||= 40
      opts[:rating] ||= "R"
      opts[:gravatar_id] = Digest::MD5.hexdigest(person.email.strip)      
      attrs = {}
      attrs[:src] = "http://www.gravatar.com/avatar.php?#{opts.to_params}"
      attrs[:class] = "gravatar"
      
      out = self_closing_tag(:img, attrs) unless person.nil?
    end
    
    def atom_link(feed_url, opts = {})
      opts[:text] ||= "Subscribe"
      link_to( opts[:text], feed_url, :rel => "alternate",  :type => "application/atom+xml", :class => "feed")
    end
    
    def paginate_links(url_name, page, opts = {})
      return "" if page.pager.number_of_pages < 2
      opts[:previous] ||= "Previous"
      opts[:next] ||= "Next"
      opts[:pages] ||= 5
      pager = page.pager
      
      out = "<ul class='page_links'>"
      
      out << "<li>#{link_to(opts[:previous], paginate_url(url_name, page.prev.number, opts))}</li>" if page.prev?
      
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
    
    # organises the count and text for the comments link
    def comment_count_text(obj)
      if obj.published?
        count = obj.comment_count
        type = ""
      else
        count = obj.pending_comment_count
        type = "Pending "
      end
      
      "#{type}Comments (#{count})"
    end
      
    def delete_button(named_url, obj, text, opts = {})
      form_for obj, {:action => url(named_url), :method => :delete}.merge(opts) do
        puts button(text, :class => "delete")
      end            
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