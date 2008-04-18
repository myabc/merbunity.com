module Merbunity
  module PublishableHelpers
    
    # yields to the block if the object is pending?
    def with_pending(obj)
      yield if obj.pending?
    end
    
    # yeilds to the block if the object is published?
    def with_published(obj)
      yield if obj.published?
    end
    
    # yields to teh block if the object is a draft
    def with_draft(obj)
      yield if obj.draft?
    end
    
    def for_publishers(obj = nil)
      if obj.nil? || obj.pending?
        yield if current_person.publisher? || current_person.admin?
      else
        yield if current_person.can_publish?(obj)
      end
    end
    
    def publish_button(url)
      out =<<-EOF
        <form method="post" action="#{url}"><input type='hidden' name='_method' value='PUT' /><button>Publish</button></form>
      EOF
    end
  end
end