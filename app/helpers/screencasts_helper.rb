module Merb
    module ScreencastsHelper
      def section_menu_items
        items = []
        if logged_in?
          items << link_to("My Pending",  url(:my_pending_screencasts))   
          items << link_to("All Pending", url(:pending_screencasts)) if current_person.admin? || current_person.publisher?
          items << link_to("Drafts",      url(:drafts_screencasts))
        end
        items
      end
    end
end