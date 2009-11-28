module Merbunity
  module MenuHelper

    @@_top_level_menu_items = nil

    # Use this module mixed into the application class to provide a menu and submenues for the site.

    def site_menu
      haml_tag(:ul, :id => "mainNav") do
        if thrown_content?(:feed_url)
          haml_tag(:li){ puts link_to("Subscribe to a feed for this page", catch_content(:feed_url), :id => "currentFeed")}
        end

        top_level_menu_items.each do |controller, text, location|
          anchor_opts = {:id => "#{text}Nav"}
          if (request.uri == location || self.class == controller)
            li_opts = {:class => "current"}
            anchor_opts[:class] = "current"
          else
            li_opts = {}
          end
          haml_tag(:li, li_opts) do
            puts link_to(text, location, anchor_opts)
            if self.respond_to?(:section_menu_items) && li_opts[:class] == "current"
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
        [Tutorials,         "Tutorials",    url(:tutorials)],
        [nil,         "People",       url(:people)],
        #[nil,         "Blogs",        url(:blogs)],
        [nil,         "Sites",        url(:sites)],
        [nil,         "Projects",     url(:projects)],
        [nil,         "About",        url(:about)]
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
