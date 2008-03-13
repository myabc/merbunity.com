module Merb
    module ScreencastsHelper
      def section_menu_items
        items = []
        items << link_to("My Pending",  url(:my_pending_screencasts))   
        items << link_to("All Pending", url(:pending_screencasts))
        items << link_to("Drafts",      url(:drafts_screencasts))
        items
      end
    end
end