module Merbunity
  module Publishable
    
    def self.included(base)
      base.class_eval do
        property        :published_on,          :datetime
        before_create   :set_initial_published_status
        
        belongs_to :owner, :class_name => "Person"
 
        def self.pending(opts={})
          self.all(opts.merge!(:published_on => nil))
        end
        
        def self.published(opts={})
          self.all(opts.merge!(:published_on.not => nil))
        end
        
        def self.find_published(id)
          self.first(:id => id, :published_on.not => nil)
        end          
        
      end
      
      base.send(:include, InstanceMethods)
    end
    
    module InstanceMethods
     def pending?
       @published_on.nil?
     end

     def published?
       !@published_on.nil?
     end

     def publish!
       self.send(:set_publish_data)
       save
     end

     private 
     def set_publish_data
       @published_on = DateTime.now
     end

     def set_initial_published_status
       self.send(:set_publish_data) if self.owner.publisher?
     end
   end
 end
end