module Merb
  module PendingHelper
    # Renders a button to html for publishing
    def publish_button!(cast)
        form_attrs = {:action => url(:publish, cast), :method => :put}
        fake_form_method = set_form_method(form_attrs, cast)
        
        button = ""
        button << open_tag(:form, form_attrs )
        button << generate_fake_form_method(fake_form_method)
        button << tag(:button, "Publish", :class => "publish")
        button << '</form>'
        button
    end  
  end
end
