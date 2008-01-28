module Merb
  module GlobalHelper
    def set_page_title(title)
      @__page_title = title
    end
    
    def set_page_heading(heading)
      @__page_heading = heading
    end
    
    def page_title
      @__page_title || ("Merbcasts #{@__page_heading}")
    end
    
    def page_heading
      @__page_heading || "Merbcasts"
    end 
    
    def cast_title(cast)
      "##{cast.cast_number || "??"} - #{cast.title}"
    end
        
  end
end    