class CommentsNewsItems
  include DataMapper::Resource
  
  storage_names[:default] = "comments_news_items"
  
  property :comment_id, Integer, :key => true
  property :news_item_id, Integer, :key => true
  
  belongs_to :comment
  belongs_to :news_item
  
end