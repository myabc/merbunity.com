class NewsItem
  include DataMapper::Resource
  include Merbunity::WhistlerHelpers::DataMapper
  
  property :id,           Integer, :serial => true
  property :body,         DataMapper::Types::Text
  property :description,  DataMapper::Types::Text
  property :title,        String
  property :created_at,   DateTime
  property :updated_at,   DateTime
  
  is_commentable
  
  belongs_to :owner, :class_name => "Person"
  
  whistler_properties :body, :description, :title
  
  validates_present :title,:description
  validates_present :owner
  
  validates_with_method :valid_owner?
  
  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body.gsub(/<code.*?<\/code>/mi){|s| s.gsub(/&lt;/,"<")}).to_html
  end
  
  def published?
    true
  end 
  
  def viewable_by?(user = nil); return true; end
  def editable_by?(user = nil); ((!user.nil? && user != :false) && (user.admin? || user == self.owner)); end
  def destroyable_by?(user = nil); ((!user.nil? && user != :false) && user.admin?); end
  def publishable_by?(user); ((!user.nil? && user != :false) && (user.admin? || user.publisher?));  end
  
  protected
  
  def valid_owner?
    if new_record?
      return [false, "must be a publisher, or admin.  Sorry"]  if self.owner.nil? || !(self.owner.publisher? || self.owner.admin?)
    end
    true
  end
end