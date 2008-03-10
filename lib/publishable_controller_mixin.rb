module Merbunity
  module PublishableController
    # def self.included(base)
    #   base.class_eval do
    #     cattr_accessor :publishable_klass, :publishable_collection_ivar_name, :publishable_object_ivar_name
    #     
    #     def self.publishable_resource(klass)
    #       self.publishable_klass = klass
    #       send(:include, Merbunity::PublishableController::Setup)
    #     end
    #   end
    # end
    
    module Setup
    
      def self.included(base)
        base.class_eval do
        
          before :login_required, :only => [:pending]

          @@publishable_object_iavr_name = publishable_klass.name.downcase.snake_case
          @@publishable_collection_ivar_name = @@publishable_object_iavr_name.pluralize

          def pending
            raise InternalServerError unless self.class.publishable_klass
            params[:id].nil? ? pending_index : pending_item(params[:id])
          end

          protected
          def pending_index
            klass = self.class.publishable_klass
            ivar_name = self.class.publishable_collection_ivar_name
            objects = klass.published(:limit => 10, :order => "published_on DESC")
            instance_variable_set( "@#{ivar_name}", objects)
            display object      
          end

          def pending_item(id)
            klass = self.class.publishable_klass
            ivar_name = self.class.publishable_object_iavr_name
            object = klass.find_published(id)
            raise NotFound unless object
            instance_variable_set( "@#{ivar_name}", object)
            display object
          end
        end
      end           
    end
  end
end

# Merb::BootLoader.before_app_loads do
#   Merb::Controller.send(:include, Merbunity::PublishableController)
# end

module Merb
  class Controller
   cattr_accessor :publishable_klass, :publishable_collection_ivar_name, :publishable_object_ivar_name
    
    def self.publishable_resource(klass)
      self.publishable_klass = klass
      send(:include, Merbunity::PublishableController::Setup)
    end
  end
end

  