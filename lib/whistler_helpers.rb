module Merbunity
  module WhistlerHelpers
    module DataMapper
    
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end
    
      module ClassMethods
      
        def whistler_properties(*props)
          @_whistler_properties = props.flatten.uniq

          before_save :whistle      
        end

        def get_whistler_properties
          @_whistler_properties
        end
      
      end
    
      module InstanceMethods
        private
        def whistle
          return unless self.dirty?
          self.class.get_whistler_properties.each do |prop|
            ivar = self.send(prop)
            self.send("#{prop}=".to_sym, (Whistler.white_list(self.send(prop)) unless ivar.nil? || !dirty_attributes.include?(prop)))
          end
          
        end
      end
      
    end
  end
end

Merb::BootLoader.before_app_loads do
  DataMapper::Base.send(:include, Merbunity::WhistlerHelpers::DataMapper)
end