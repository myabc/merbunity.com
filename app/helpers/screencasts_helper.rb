module Merb
    module ScreencastsHelper
      
      def section_menu_items
        items ||= []
        items << ["New",          url(:new_screencast)]
        if logged_in?
          items << ["My Pending",   url(:my_pending_screencasts)]
          items << ["All Penging",  url(:pending_screencasts)] if current_person.admin? || current_person.publisher?
          items << ["Drafts",       url(:drafts_screencasts)]
        end
        items
      end
      
    end
end