unless defined?(Tutorial)
Comment
class Tutorial
  include DataMapper::Resource

  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable

  property :id,                       Integer,                  :serial => true
  property :title,                    String,                   :nullable => false
  property :description,              String,                   :nullable => false, :length => 255
  property :body,                     Text,                     :nullable => false



  # Commentable stuff ----------- here in anticipation of snoflake schema style polymorphism
  has n,  :commentable_tutorials, :class_name => "CommentableTutorials", :child_key => [:tutorial_id]
  
  has n,  :comments, 
          :through => :commentable_tutorials, 
          :class_name => "Comment",
          :child_key  => [:tutorial_id],
          :remote_relationship_name => :comment,
          Tutorial.commentable_tutorials.comment.status => "published"
          
  has n,  :pending_comments, 
          :through => :commentable_tutorials, 
          :class_name => "Comment", 
          :child_key  => [:tutorial_id],
          :remote_relationship_name => :comment,
          Tutorial.commentable_tutorials.comment.status => "pending"
          
end
end
