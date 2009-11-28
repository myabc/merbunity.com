module Merbunity
  module WhistlerHelpers
    module DataMapper

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods

        def whistler_properties(*props)
          before :save, :whistle if @_whistler_properties.nil?
          @_whistler_properties = props.flatten.uniq
        end

        def get_whistler_properties
          @_whistler_properties
        end

      end

      module InstanceMethods
        private
        def whistle
          self.class.get_whistler_properties.each do |prop|
            ivar = self.send(prop)
            self.send("#{prop}=".to_sym, (Whistler.white_list(self.send(prop)))) if !ivar.nil? && (new_record? || dirty_attributes.keys.detect{|a| a.name == prop})
          end
        end
      end

    end
  end
end
