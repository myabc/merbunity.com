class CommentsScreencasts 
  include DataMapper::Resource
  
  storage_names[:default] = "comments_screencasts"

  property :comment_id,     Integer, :key => true
  property :screencast_id,  Integer, :key => true  
  
  belongs_to :screencast
  belongs_to :comment
end