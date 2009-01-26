module DataMapper
  module Is
   module Draftable
     
     module BaseMethods
       def is_draftable(*props)
         @draftable_fields = props
         props_string = ""
         props.each do |p|
           prop = self.properties[p]
           props_string << "property #{p.inspect}, #{prop.type}, #{prop.options.inspect}\n"
         end
       
         self.class_eval <<-RUBY
           class Draft
             include DataMapper::Resource
             property :id, Serial
             #{props_string}
           
             belongs_to :#{self.name.snake_case}, :class_name => #{self.name.inspect}
           
           end
         RUBY
       
         self.class_eval do
           include DataMapper::Is::Draftable::InstanceMethods
           extend  DataMapper::Is::Draftable::ClassMethods
           has 1, :draft, :class_name => "#{self.name}::Draft"
         
           property :published_on, DateTime, :nullable => true, :default => nil
         end
       
         self.default_scope.update(:published_on.not => nil)
       end # is_draftable
     end
     
     module InstanceMethods
       def save_draft
         save if new_record?
         if draft.nil?
           self.draft = self.class.const_get(:Draft).new
           self.class.draftable_fields.each do |f|
             self.draft.send(:"#{f}=", self.send(f))
           end
           draft.save
         end
       end
       
       def has_draft?
         !draft.nil?
       end
       
       def publish_draft!
         raise "No Draft Found" unless has_draft?
         self.class.draftable_fields.each do |f|
           self.send(:"#{f}=", self.draft.send(f))
         end
         draft.destroy
         self.draft = nil
         publish!
         reload
       end
       
       def published?
         !published_on.blank?
       end
       
       def publish!
         return false unless valid?
         self.published_on = DateTime.now
         save
       end
     end # InstanceMethods
     
     module ClassMethods
       def draftable_fields
         @draftable_fields
       end
       
       def unpublished(params = {})
         with_scope(:published_on => nil) do
           all(params)
         end
       end
       
       def draftable?
         true
       end
       
     end # ClassMethods
   end # Draftable
  end # Is
end # DataMapper

DataMapper::Model.append_extensions(DataMapper::Is::Draftable::BaseMethods)