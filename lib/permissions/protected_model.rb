module Merbunity
  module Permissions
    module ProtectedModel


      def viewable_by?(user)
        if !user
          return self.published?
        end

        return true if self.published?

        return true if user.admin?
        return true if user.publisher?

        return self.owner == user ? true : false
      end

      def editable_by?(user)
        return false unless user
        return true if user.admin?
        return true if self.owner == user
        false
      end

      def destroyable_by?(user)
        return false unless user
        return true if user.admin?
        if self.owner == user
          if self.respond_to?(:published_on)
            return true if self.published_on.nil?
          else
            return true
          end
        end
        false
      end

      def publishable_by?(user)
        return false unless user
        return true if self.owner == user
        return true if user.admin?
        return true if user.publisher?
      end
    end
  end
end
