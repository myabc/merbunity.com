module Merbunity
  module Publishable
    
    def self.publishables_to_be_publisher(val = nil)
      @publishables_to_be_publisher ||= 3
      @publishables_to_be_publisher = val unless val.nil?
      @publishables_to_be_publisher
    end
    # PUBLISHABLES_TO_BE_PUBLISHER = 3
    
    def self.included(base)
      base.class_eval do
        
        property        :published_on,          DateTime                      unless self.properties.any?{|p| p.name == :published_on }
        property        :published_status,      String, :default => "Draft"   unless self.properties.any?{|p| p.name == :published_status }
        property        :created_at,            DateTime                      unless self.properties.any?{|p| p.name == :created_at }
        property        :updated_at,            DateTime                      unless self.properties.any?{|p| p.name == :updated_at }
        
        # before_create   :set_initial_published_status
        
        belongs_to :owner,     :class_name => "Person"
        belongs_to :publisher, :class_name => "Person"

        before :save, :set_publishable_defaults
        
        def self.status_values
          @status_values ||= {:published => "Published", :pending => "Pending", :draft => "Draft"}
        end
 
        def self.pending(opts={})
          self.all({:order => [:created_at.desc]}.merge!(opts).merge!(:published_status => status_values[:pending]))
        end
        
        def self.published(opts={})
          self.all({:order => [:published_on.desc]}.merge!(opts).merge!(:published_status => status_values[:published]))
        end
        
        def self.find_published(id)
          self.first(:id => id, :published_status => status_values[:published])
        end         
        
        def self.drafts(opts = {}) 
          # self.all({:order => "created_at DESC"}.merge!(opts).merge!(:published_on => nil, :draft_status => true))
          self.all({:order => [:created_at.desc]}.merge!(opts).merge!(:published_status => status_values[:draft]))
        end
        
        def self.published_count(opts = {})
          self.count(opts.merge!(:published_status => status_values[:published]))
        end
        
        def self.publishables_to_be_publisher(val = nil)
          @publishables_to_be_publisher ||= 3
          @publishables_to_be_publisher = val unless val.nil?
          @publishables_to_be_publisher
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
       @published_status == self.class.status_values[:pending]
     end

     def published?
       @published_status == self.class.status_values[:published]
     end
     
     def draft?
       @published_status ||= self.class.status_values[:draft]
       @published_status == self.class.status_values[:draft]
     end

     def publish!(publisher)
       if self.publishable_by?(publisher)
         self.send(:set_publish_data, publisher)
         save
       end
     end
     
     private 
     def set_publish_data(the_publisher)
       if the_publisher.publisher?
         # This is being published for realz
         unless self.published?
           @published_on = DateTime.now
           self.publisher = the_publisher
           self.owner.published_item_count = (self.owner.published_item_count || 0) + 1
           self.owner.save
           
           # make the owner a publisher if they have published enough articles
           self.owner.make_publisher! if !self.owner.publisher? && self.owner.published_item_count >= self.class.publishables_to_be_publisher
           self.published_status = self.class.status_values[:published]
         end
       elsif the_publisher == self.owner
         # This is going from draft to published
         self.published_status = self.class.status_values[:pending]
       else
         #This is only a draft
         self.published_status = self.class.status_values[:draft]
       end
     end

     def set_initial_published_status
       self.published_status = self.class.status_values[:draft]
       # self.send(:set_publish_data, self.owner) if self.owner.publisher?
     end
     
     # Shoudln't need this :(
     def set_publishable_defaults
       @published_status ||= self.class.status_values[:draft]
     end
   end
 end
end