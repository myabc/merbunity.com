module Merbunity
  module Permissions
    module ProtectedModel
      
      
      def viewable_by?(user)
        if user.nil? || user == :false
          return self.published?
        end
        
        return true if user.admin?
        return true if user.publisher?
        
        return self.owner == user ? true : false
      end
      
      def editable_by?(user)
        return false if user.nil? || user == :false
        return true if user.admin?
        return true if self.owner == user
        false
      end
      
      def destroyable_by?(user)
        return false if user.nil? || user == :false
        return true if user.admin?
        return true if self.owner == user
        false
      end
      
      def publishable_by?(user)
        return false if user.nil? || user == :false
        return true if user.admin?
        return true if user.publisher?
      end      
    end
  end
end