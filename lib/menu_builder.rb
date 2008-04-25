module Merbunity
  module MenuHelper
    
    @@_top_level_menu_items = nil

    # Use this module mixed into the application class to provide a menu and submenues for the site.
    
    def site_menu
      haml_tag(:ul, :id => "mainNav") do
        top_level_menu_items.each do |controller, text, location|
          opts = (request.uri == location || self.class == controller) ? {:class => "current"} : {}
          haml_tag(:li, opts) do
            puts link_to(text, location, opts)
            if self.respond_to?(:section_menu_items) && opts[:class] == "current"
              unless section_menu_items.empty?
                build_menu_from_array(section_menu_items) 
              end
            end
            
          end
        end
      end
    end
    
    private 
    def top_level_menu_items
      @@_top_level_menu_items ||= [  
        [News,        "News",         url(:news)],
        [Screencasts, "Screencasts",  url(:screencasts)],
        [nil,         "Tutorials",    url(:tutorials)],
        [nil,         "People",       url(:people)],
        [nil,         "Blogs",        url(:blogs)],
        [nil,         "Sites",        url(:sites)],
        [nil,         "Projects",     url(:projects)]
      ]
    end

    # Used to build submenues
    def build_menu_from_array(array)
      haml_tag(:ul) do
        array.each do |text, location|
          opts = (request.uri == location) ? {:class => "current"} : {}
          haml_tag(:li, opts) do
            puts link_to(text, location, opts)
          end
        end
      end
    end
  
  end
end