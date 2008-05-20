module Merb
  module TutorialsHelper
    
    def section_menu_items
      items ||= []
      items << ["New",          url(:new_tutorial)]
      if logged_in?
        items << ["My Pending",   url(:my_pending_tutorials)]
        items << ["All Penging",  url(:pending_tutorials)] if current_person.admin? || current_person.publisher?
        items << ["Drafts",       url(:drafts_tutorials)]
      end
      items << ["Subscribe", "http://feeds.feedburner.com/Merbunity-Tutorials"]
      items
    end
  end # TutorialsHelper
end # Merb
