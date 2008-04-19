module Merb
  module NewsHelper
    def section_menu_items
      items = []
      if logged_in?
        items << link_to("Got Some News?",  url(:new_news)) if current_person.admin? || current_person.publisher?
      end
      items
    end
    
    def section_menu_header
      "News Actions"
    end
  end
end