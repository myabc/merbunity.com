class CommentableTutorials
  include DataMapper::Resource
  
  storage_names[:default] = "comments_tutorials"
  
  property :comment_id, Integer, :key => true
  property :tutorial_id, Integer, :key => true
  
  belongs_to :comment 
  belongs_to :tutorial
end