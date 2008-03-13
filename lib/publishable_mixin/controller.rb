module Merbunity
  module PublishableController
    
    module Setup
    
      def self.included(base)
        base.class_eval do
          
          # TODO need to include a publish method in here.
                
          before Proc.new{ |c| c.login_required }, :only => [:pending, :my_pending]
          
          @@publishable_collection_ivar_name = self.publishable_klass.name.snake_case.pluralize
          
          def pending
            return my_pending unless current_person.publisher?
            klass = self.class.publishable_klass
            collection = klass.pending(:limit => 10)
            instance_variable_set("@#{@@publishable_collection_ivar_name}", collection)
            display collection            
          end
          
          def my_pending
            ivar = @@publishable_collection_ivar_name
            obj = instance_variable_set("@#{ivar}",current_person.send("pending_#{ivar}".to_sym))
            display obj, :pending
          end
          
          def publish(id)
            id = params[:id]
            ivar = @@publishable_collection_ivar_name.singularize
            obj = klass.find(id)
            raise NotFound unless obj
            obj.publish! if current_user.can_publish?(obj)
            redirect url("#{@@publishable_collection_ivar_name.singularize}".to_sym, obj)
          end
            
            
        end
                
      end           
    
    end
  end
end


module Merb
  class Controller
    
    def self.publishable_resource(klass)
      self.cattr_accessor :publishable_klass, :publishable_collection_ivar_name
      self.publishable_klass = klass
      raise "Must set a publishable_klass in your controller that includes Merbunity::Publishable" unless klass.include?(Merbunity::Publishable)
      send(:include, Merbunity::PublishableController::Setup)
    end
  end
end

  