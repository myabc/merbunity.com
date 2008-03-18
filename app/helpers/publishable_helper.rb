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
    
  end
end