module Merbunity
  module PublishableController
    
    module Setup
    
      def self.included(base)
        base.class_eval do
          
          # TODO need to include a publish method in here.
                
          before Proc.new{ |c| c.login_required }, :only => [:pending, :my_pending, :publish, :drafts]
          
          self.publishable_collection_ivar_name = self.publishable_klass.name.snake_case.pluralize
          self.publishable_singular_name = self.publishable_klass.name.snake_case.singularize
          
          def pending
            return my_pending unless current_person.publisher?
            klass = self.class.publishable_klass
            collection = klass.pending(:limit => 10)
            instance_variable_set("@#{self.class.publishable_collection_ivar_name}", collection)
            @page_header = "Pending #{self.class.publishable_collection_ivar_name.capitalize}"
            display collection            
          end
          
          def my_pending
            ivar = self.class.publishable_collection_ivar_name
            obj = instance_variable_set("@#{ivar}",current_person.send("pending_#{ivar}".to_sym))
            @page_header =  "My Pending #{self.class.publishable_collection_ivar_name.capitalize}"
            display obj, :pending
          end
          
          def publish(id)
            klass = self.class.publishable_klass
            ivar = self.class.publishable_collection_ivar_name.singularize
            obj = klass.find(id)
            raise NotFound unless obj
            obj.publish!(current_person) if current_person.can_publish?(obj)
            redirect url("#{self.class.publishable_collection_ivar_name.singularize}".to_sym, obj)
          end
          
          def drafts
            klass = self.class.publishable_klass
            ivar = self.class.publishable_collection_ivar_name
            collection = instance_variable_set("@#{ivar}", current_person.send("draft_#{ivar}".to_sym))
            @page_header =  "Draft #{self.class.publishable_collection_ivar_name.capitalize}"
            display collection, :pending     
          end
        end
        base.class_eval(get_controller_parts(base))
                
      end           
    
      def self.get_controller_parts(base)
        def_for_controller = <<-EOD
          before :non_publisher_help    
          before :login_required, :only => [:new, :create, :edit, :update, :destroy]
          before :find_#{base.publishable_collection_ivar_name}, :only => [:destroy, :show, :edit, :update]

          only_provides :html, :only => [:new, :edit]

          def index(page = 0)
            provides :atom
            @pager = Paginator.new(#{base.publishable_klass}.published_count, 10) do |offset, per_page|
                          #{base.publishable_klass}.published(:limit => per_page, :offset => offset)
                     end
            @page = @pager.page(page)
            @#{base.publishable_collection_ivar_name} = @page.items    
            display @#{base.publishable_collection_ivar_name}
          end

          def show(id)
            raise Unauthorized unless @#{base.publishable_singular_name}.viewable_by?(current_person)
            display @#{base.publishable_singular_name}
          end

          def new(#{base.publishable_singular_name} = {})
            @#{base.publishable_singular_name} = #{base.publishable_klass}.new(#{base.publishable_singular_name})
            render
          end

          def edit(id)
            raise Unauthorized unless current_person.can_edit?(@#{base.publishable_singular_name})
            render
          end

          def create(#{base.publishable_singular_name})
            @#{base.publishable_singular_name} = #{base.publishable_klass}.new(#{base.publishable_singular_name}.merge(:owner => current_person))
            if @#{base.publishable_singular_name}.save
              flash[:notice] = "Saved your #{base.publishable_singular_name}"
              redirect url(:#{base.publishable_singular_name}, @#{base.publishable_singular_name})
            else
              flash[:error] = "Something went wrong"
              render :new
            end
          end

          def update(id, #{base.publishable_singular_name} = {})
            raise Unauthorized unless current_person.can_edit?(@#{base.publishable_singular_name})
            @#{base.publishable_singular_name}.published_status = #{base.publishable_klass}.status_values[:draft_status] if params[:save_as_draft] == "1"

            # There's a bug which won't allow DM to update attributes properly.  If they haven't changed, the attributes
            # # are set to nil :\
            # #{base.publishable_singular_name}.each do |k,v|
            #   @#{base.publishable_singular_name}.send(\"\#{k}=\",v) unless @#{base.publishable_singular_name}.send(k.to_sym) == v
            # end

            if @#{base.publishable_singular_name}.update_attributes(#{base.publishable_singular_name})
              flash[:notice] = "Updated your #{base.publishable_singular_name}"
              redirect url(:#{base.publishable_singular_name}, @#{base.publishable_singular_name})
            else
              flash[:error] = "There was an error editing your #{base.publishable_klass}"
              render :edit
            end
          end

          def destroy(id)
            raise Unauthorized unless current_person.can_destroy?(@#{base.publishable_singular_name})
            if @#{base.publishable_singular_name}.destroy!
              flash[:notice] = "#{base.publishable_klass} Deleted"
              redirect url(:#{base.publishable_collection_ivar_name})
            else
              flash[:error] = "Could not delete your #{base.publishable_klass}"
              raise BadRequest
            end
          end

          private

          def find_#{base.publishable_collection_ivar_name}
            @#{base.publishable_singular_name} = #{base.publishable_klass}.first(params[:id])
            raise NotFound if @#{base.publishable_singular_name}.nil?
            @#{base.publishable_singular_name}
          end

          def ensure_logged_in_for_pending
            @#{base.publishable_singular_name} = #{base.publishable_klass}.first(:id => params[:id])
            throw(:halt, :access_denied) if(@#{base.publishable_singular_name}.nil? || !@#{base.publishable_singular_name}.viewable_by?(current_person))
          end

          def non_publisher_help
            return true if !logged_in? || current_person.publisher?
            partial("shared/publishable/non_publisher_tip", :format => :html)
          end
        EOD
      end
    
    end
  end
end


module Merb
  class Controller
    
    def self.publishable_resource(klass)
      self.cattr_accessor :publishable_klass, :publishable_collection_ivar_name, :publishable_singular_name
      self.publishable_klass = klass
      raise "Must set a publishable_klass in your controller that includes Merbunity::Publishable" unless klass.include?(Merbunity::Publishable)
      send(:include, Merbunity::PublishableController::Setup)
    end
  end
end

  