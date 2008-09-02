class Comment
  include DataMapper::Resource
  
  include Merbunity::WhistlerHelpers::DataMapper
  
  property :id,                 Integer, :serial => true
  property :body,               Text, :lazy => false
  property :created_at,         DateTime
  property :status,             String
  property :commentable_class,  MerbunityClass
  
  belongs_to :owner, :class_name => "Person", :child_key => [:owner_id]
  
  has 1, :commentable_screencasts, :class_name => "CommentableScreencasts", :child_key => [:comment_id]
  has 1, :screencast, :through => :commentable_screencasts
  
  has 1, :commentable_tutorials,   :class_name => "CommentableTutorials", :child_key => [:comment_id]
  has 1, :tutorial, :through => :commentable_tutorials
  
  has 1, :commentable_news_items,  :class_name => "CommentableNewsItems", :child_key => [:comment_id]
  has 1, :news_item, :through  => :commentable_news_items
  
  validates_present :owner, :groups => :create
  
  whistler_properties :body

end