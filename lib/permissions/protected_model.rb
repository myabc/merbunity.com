module Merbunity
  module Permissions
    module ProtectedModel
      
      
      # TODO This needs to be tightened up.  Do that via controller specs
      def viewable_by?(user)
        if user.nil? || user == :false
          return self.published?
        end
        
        if user.publisher?
          return true
        end
                
        if self.respond_to?(:owner)
          return self.owner == user ? true : false
        end
        
        false
      end
      
      def editable_by?(user)
        return false if user.nil? || user == :false
        
        return true if user.publisher?
        return true if self.owner == user
        false
      end
      
      def destroyable_by?(user)
        return false if user.nil? || user == :false
        return true if user.publisher?
        return true if self.owner == user
        false
      end
      
    end
  end
end