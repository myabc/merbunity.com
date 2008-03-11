module Merbunity
  module PublishableController
    
    module Setup
    
      def self.included(base)
        base.class_eval do
        
          # before :login_required, :only => [:pending]
          @@publishable_collection_ivar_name = self.publishable_klass.name.snake_case.pluralize
          
          def pending
            return my_pending unless current_user.publisher?
            klass = self.class.publishable_klass
            instance_variable_set("@#{@@publishable_collection_ivar_name}", klass)
            klass.published(:limit => 10)
            # 
            # if params[:id]
            #   ivar_name = self.class.publishable_object_ivar_name
            #   object = klass.find_published(params[:id])
            #   the_template = "screencasts/show.#{content_type}"
            # else
            #   ivar_name = self.class.publishable_collection_ivar_name
            #   objects = klass.published(:limit => 10, :order => "published_on DESC")
            #   the_template = "screencasts/index.#{content_type}"
            # end
            # instance_variable_set( "@#{ivar_name}", objects)
            # render :template => the_template
          end
          
          def my_pending
            ivar = @@publishable_collection_ivar_name
            instance_variable_set("@#{ivar}",current_user.send("pending_#{ivar}".to_sym))
            render :pending
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
   cattr_accessor :publishable_klass, :publishable_collection_ivar_name
    
    def self.publishable_resource(klass)
      self.publishable_klass = klass
      raise "Must set a publishable_klass in your controller that includes Merbunity::Publishable" unless klass.include?(Merbunity::Publishable)
      send(:include, Merbunity::PublishableController::Setup)
    end
  end
end

  