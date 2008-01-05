module Merb
  module GlobalHelper
    def set_page_title(title)
      @__page_title = title
    end
    
    def set_page_heading(heading)
      @__page_heading = heading
    end
    
    def page_title
      @__page_title || @__page_heading || "Merbcasts"
    end
    
    def page_heading
      @__page_heading || "Merbcasts"
    end     
  end
end    