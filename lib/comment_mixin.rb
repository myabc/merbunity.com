module Merbunity
  module Comments
    
    module Published
      def self.included(base)
        comment_join_name = "#{base.name}Comment".snake_case.pluralize
        plural_base = base.name.snake_case.pluralize
        base_name = "#{base.name.snake_case}".to_sym
        join_klass = "#{base.name}Comment"
        # Setup the join model
        # join_klass = Object.full_const_set("::#{base.name}Comment", Object.clone)
        stuff =<<-EOF
          class ::#{base.name}Comment
            include ::DataMapper::Resource
            storage_names[:default] = "comments_#{plural_base}"
            property :#{base_name}_id,  Integer, :key => true
            property :comment_id,       Integer, :key => true
            belongs_to :#{base_name}
            belongs_to :comment
          end
        EOF
        Object.class_eval stuff 
        stuff =<<-EOF
          class #{base.name}
            property :comment_count, Integer, :default => 0
            has n, :#{comment_join_name}, :class_name => "#{join_klass}", :child_key => [:#{base_name}_id]
            # has n, :comments => :#{comment_join_name}, :class_name => "Comment"
          end
        EOF
        Object.class_eval stuff
        stuff =<<-EOF
          class Comment
            has n, :#{comment_join_name}, :class_name => "#{join_klass}", :child_key => [:comment_id]
            # has n, :#{plural_base} => :#{comment_join_name}
          end
        EOF
        Object.class_eval stuff        

        
        

          
          
          
          # We want a has many through on the base and the comment
          
          
          
          # # has_and_belongs_to_many :comments , 
          #                         :join_table => "comments_#{base.name.snake_case.pluralize}",  
          #                         :class => "Comment",
          #                         :foreign_name => "#{base.name.snake_case.pluralize}".to_sym
          #         
          # # Comment.send(:has_and_belongs_to_many, 
          #                         "#{base.name.snake_case.pluralize}".to_sym, 
          #                         :join_table => "comments_#{base.name.snake_case.pluralize}", 
          #                         :class => "#{base.name}",
          #                         :foreign_name => :comments)

          # 
          # before :create, :set_default_comment_count
          # 
          # private 
          # def set_default_comment_count
          #   self.comment_count ||= 0
          # end
          # 
        # end #class_eval
        
      end  # self.included 
    end # Published
    
    module Pending
      def self.included(base)
        # base.class_eval do
          # property :pending_comment_count, Integer, :default => 0
        #   # has_and_belongs_to_many :pending_comments,  
        #                           :class => "Comment", 
        #                           :join_table => "pending_comments_#{base.name.snake_case.pluralize}",
        #                           :foreign_name => "pending_#{base.name.snake_case.pluralize}".to_sym
        #      
        #   Comment.send( :has_and_belongs_to_many, 
        #                           "pending_#{base.name.snake_case.pluralize}".to_sym, 
        #                           :join_table => "pending_comments_#{base.name.snake_case.pluralize}", 
        #                           :class => "#{base.name}",
        #                           :foreign_name => :pending_comments)
        #   property :pending_comment_count, :integer, :default => 0
        #   
        #   before_create :set_default_pending_comment_count
        #   
        #   private 
        #   def set_default_pending_comment_count
        #     self.pending_comment_count ||= 0
        #   end
        # end # class_eval
      end # self.included
    end # Pending
    
  end
end

module DataMapper
  module Resource
    module ClassMethods
      def is_commentable(*types)
        types = [:published] if types.empty?
        self.send(:include, Merbunity::Comments::Published) if types.include? :published
        # send(:include, Merbunity::Comments::Pending)   if types.include? :pending
      end
    end
  end
end
