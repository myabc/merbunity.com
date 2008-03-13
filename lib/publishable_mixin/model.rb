module Merbunity
  module Publishable
    
    def self.included(base)
      base.class_eval do
        property        :published_on,          :datetime
        property        :draft_status,                 :boolean
        
        property :created_at, :datetime unless self.properties.any?{|p| p.name == :created_at }
        
        # before_create   :set_initial_published_status
        
        belongs_to :owner, :class => "Person"
        belongs_to :publisher, :class => "Person"
        
        before_create :set_publishable_defaults
        
        validates_presence_of   :owner, :groups => [:create]
 
        def self.pending(opts={})
          self.all({:order => "created_at DESC"}.merge!(opts).merge!(:published_on => nil, :draft_status => false))
        end
        
        def self.published(opts={})
          self.all({:order => "published_on DESC"}.merge!(opts).merge!(:published_on.not => nil))
        end
        
        def self.find_published(id)
          self.first(:id => id, :published_on.not => nil)
        end         
        
        def self.drafts(opts = {}) 
          self.all({:order => "created_at DESC"}.merge!(opts).merge!(:published_on => nil, :draft_status => true))
        end
        
      end
      
      base.send(:include, InstanceMethods)
      person_methods =<<-EOF
        def pending_#{bn = base.name.snake_case.pluralize}
          @_pending#{bn} ||= #{base.name}.pending(:owner_id => self.id)
        end
        
        def #{bn}
          @_#{bn} ||= #{base.name}.all(:owner_id => self.id)
        end
        
        def published_#{bn}
          @_published_#{bn} ||= #{base.name}.published(:owner_id => self.id)
        end
        
        def draft_#{bn}
          @_draft_#{bn} ||= #{base.name}.drafts(:owner_id => self.id)
        end
        
      EOF
      Person.class_eval(person_methods)
      
    end
    
    module InstanceMethods
     def pending?
       @published_on.nil? && !self.draft?
     end

     def published?
       !@published_on.nil?
     end

     def publish!(publisher)
       if self.publishable_by?(publisher)
         self.send(:set_publish_data, publisher)
         save
       end
     end
     
     def draft?
       !!(@draft_status.nil? ? true : @draft_status)
     end

     private 
     def set_publish_data(the_publisher)
       if the_publisher.publisher?
         @published_on = DateTime.now
         self.publisher = the_publisher
         self.owner.published_item_count = (self.owner.published_item_count || 0) + 1
         @draft_status = false
       else
         @draft_status = false
       end
     end

     def set_initial_published_status
       # self.send(:set_publish_data, self.owner) if self.owner.publisher?
     end
     
     # Shoudln't need this :(
     def set_publishable_defaults
       if self.published_on.nil?
         @draft_status ||= true
       else
         @draft_status = false
       end
     end
   end
 end
end