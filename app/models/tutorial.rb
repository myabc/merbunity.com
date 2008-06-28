unless defined?(Tutorial)
Comment
class Tutorial
  include DataMapper::Resource
  include Merbunity::WhistlerHelpers::DataMapper

  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable

  property :id,                       Integer,                  :serial => true
  property :title,                    String,                   :nullable => false
  property :description,              String,                   :nullable => false, :length => 255
  property :body,                     Text,                     :nullable => false

  whistler_properties :title, :body, :description


  # Commentable stuff ----------- here in anticipation of snoflake schema style polymorphism
  has n,  :commentable_tutorials, :class_name => "CommentableTutorials", :child_key => [:tutorial_id]
  
  has n,  :comments, 
          :through => :commentable_tutorials, 
          :class_name => "Comment",
          :remote_relationship_name => :comment,
          Tutorial.commentable_tutorials.comment.status => "published"
          
  has n,  :pending_comments, 
          :through => :commentable_tutorials, 
          :class_name => "Comment", 
          :remote_relationship_name => :comment,
          Tutorial.commentable_tutorials.comment.status => "pending"
          
        
  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body.gsub(/<code.*?<\/code>/mi){|s| s.gsub(/&lt;/,"<")}).to_html
  end
end
end
