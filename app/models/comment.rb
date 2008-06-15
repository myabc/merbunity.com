class Comment
  include DataMapper::Resource
  
  include Merbunity::WhistlerHelpers::DataMapper
  
  property :id,                 Integer, :serial => true
  property :body,               Text
  property :created_at,         DateTime
  property :status,             String
  property :commentable_class,  Class
  
  belongs_to :owner, :class_name => "Person"
  
  has 1, :comments_screencasts, :class_name => "CommentsScreencasts", :child_key => [:comment_id]
  has 1, :screencast, :through => :comments_screencasts
  
  has 1, :comments_tutorials,   :class_name => "CommentsTutorials", :child_key => [:comment_id]
  has 1, :tutorial, :through => :comments_tutorials
  
  has 1, :comments_news_items,  :class_name => "CommentsNewsItems", :child_key => [:comment_id]
  has 1, :news_item, :through  => :comments_news_items
  
  validates_present :owner, :groups => :create
  
  whistler_properties :body

end