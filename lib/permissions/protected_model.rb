module Merbunity
  module Permissions
    module ProtectedModel
      
      def viewable_by?(user)
        if self.respond_to?(:owner)
          return self.owner == user ? true : false
        else
          true
        end
      end
      
      def editable_by?(user)
        if self.respond_to?(:owner)
          return self.owner == user ? true : false
        else
          true
        end
      end
      
      def destroyable_by?(user)
        if self.respond_to?(:owner)
          return self.owner == user ? true : false
        else
          true
        end
      end
      
    end
  end
end