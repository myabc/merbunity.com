module Merbunity
  module Permissions
    module User
      
      def can_view?(obj)
        obj.respond_to?(:viewable_by?) ? obj.viewable_by?(self) : true
      end
      
      def can_edit?(obj)
        obj.respond_to?(:editable_by?) ? obj.editable_by?(self) : true
      end
      
      def can_destroy?(obj)
        obj.respond_to?(:destroyable_by?) ? obj.destroyable_by?(self) : true
      end
      
    end
  end
end