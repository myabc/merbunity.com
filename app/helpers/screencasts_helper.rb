module Merb
    module ScreencastsHelper
      def section_menu_items
        items = []
        if logged_in?
          items << link_to("Make a New One",  url(:new_screencast))
          items << link_to("My Pending Ones",      url(:my_pending_screencasts))   
          items << link_to("All Pending Ones",     url(:pending_screencasts)) if current_person.admin? || current_person.publisher?
          items << link_to("Drafts",          url(:drafts_screencasts))
        end
        items
      end
      
      def section_menu_header
        "Screencast Actions"
      end
    end
end