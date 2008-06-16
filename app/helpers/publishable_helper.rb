module Merbunity
  module PublishableHelpers
    
    # yields to the block if the object is pending?
    def with_pending(obj, &blk)
      yield if obj.pending?
    end
    
    # yeilds to the block if the object is published?
    def with_published(obj)
      yield if obj.published?
    end
    
    def with_unpublished(obj)
      yield unless obj.published?
    end
    
    # yields to teh block if the object is a draft
    def with_draft(obj, &blk)
      yield if obj.draft?
    end
    
    def for_publishers(obj = nil, &blk)
      return unless logged_in?
      yield if current_person.can_publish?(obj)
    end
    
    def publish_button(url)
      Merb.logger.info "PUTTING IN A PUBLISH BUTTON"
      out =<<-EOF
        <form method="post" action="#{url}"><input type='hidden' name='_method' value='PUT' /><button>Publish</button></form>
      EOF
    end
  end
end