module Merb
  module NewsHelper
    
    def section_menu_items
      items ||= []
      if logged_in?
        items << ["Got News?", url(:new_news)] if current_person.admin? || current_person.publisher?
      end
      items << ["Subscribe", url(:news, :format => "atom")]
      items
    end

  end
end