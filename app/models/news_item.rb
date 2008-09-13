unless defined?(NewsItem)
Comment
class NewsItem
  include DataMapper::Resource
  
  property :id,           Integer, :serial => true
  property :body,         DataMapper::Types::Text
  property :description,  DataMapper::Types::Text, :nullable => false
  property :title,        String, :nullable => false
  property :comment_count,Integer, :default => 0
  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :owner, :class_name => "Person", :child_key => [:owner_id]
  
  
  validates_present :owner
  
  def valid_owner?
    if new_record?
      return [false, "must be a publisher, or admin.  Sorry"]  if self.owner.nil? || !(self.owner.publisher? || self.owner.admin?)
    end
    true
  end
  
  validates_with_method :valid_owner?
  
  
  # Commentable stuff
  has n, :comments_news_items, :class_name => "CommentableNewsItems"

  has n,  :comments, 
          :through => :comments_news_items, 
          :class_name => "Comment",
          :child_key  => [:news_item_id],
          :remote_relationship_name => :comment,
          NewsItem.comments_news_items.comment.status => "published"
  
  def published?
    true
  end 
  
  def viewable_by?(user = nil); return true; end
  def editable_by?(user = nil); ((!user.nil? && user != :false) && (user.admin? || user == self.owner)); end
  def destroyable_by?(user = nil); ((!user.nil? && user != :false) && user.admin?); end
  def publishable_by?(user); ((!user.nil? && user != :false) && (user.admin? || user.publisher?));  end
  

end
end