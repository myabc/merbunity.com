module Merbunity
  module Publishable
    
    def self.included(base)
      base.class_eval do
        property        :published_on,          :datetime
        
        property :created_at, :datetime unless self.properties.any?{|p| p.name == :created_at }
        
        before_create   :set_initial_published_status
        
        belongs_to :owner, :class => "Person"
        belongs_to :publisher, :class => "Person"
        
        validates_presence_of   :owner, :groups => [:create]
 
        def self.pending(opts={})
          self.all({:order => "created_at DESC"}.merge!(opts).merge!(:published_on => nil))
        end
        
        def self.published(opts={})
          self.all({:order => "published_on DESC"}.merge!(opts).merge!(:published_on.not => nil))
        end
        
        def self.find_published(id)
          self.first(:id => id, :published_on.not => nil)
        end          
        
      end
      
      base.send(:include, InstanceMethods)
      person_methods =<<-EOF
        def pending_#{bn = base.name.snake_case.pluralize}
          @_pending#{bn} ||= #{base.name}.all(:published_on => nil, :owner_id => self.id)
        end
        
        def #{bn}
          @_#{bn} ||= #{base.name}.all(:owner_id => self.id)
        end
        
        def published_#{bn}
          @_published_#{bn} = #{base.name}.all(:published_on.not => nil, :owner_id => self.id)
        end
      EOF
      
      Person.class_eval(person_methods)
      
    end
    
    module InstanceMethods
     def pending?
       @published_on.nil?
     end

     def published?
       !@published_on.nil?
     end

     def publish!(publisher)
       self.send(:set_publish_data, publisher)
       save
     end

     private 
     def set_publish_data(publisher)
       @published_on = DateTime.now
       self.publisher = publisher
     end

     def set_initial_published_status
       # self.send(:set_publish_data, self.owner) if self.owner.publisher?
     end
   end
 end
end