class NewsItem < DataMapper::Base
  
  property :body, :text
  property :description, :text
  property :title, :string
  property :created_at, :datetime
  property :updated_at, :datetime
  
  belongs_to :owner, :class => "Person"
  
  whistler_properties :body, :description, :title
  
  validates_presence_of :title,:description
  validates_presence_of :owner
  
  validates_each :owner, :groups => [:create], :logic => lambda{
    errors.add(:owner, "must be a publisher, or admin.  Sorry") unless !self.owner.nil? && (self.owner.publisher? || self.owner.admin?)
  }
  
  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body).to_html
  end
  
  def viewable_by?(user = nil); return true; end
  def editable_by?(user = nil); ((!user.nil? && user != :false) && (user.admin? || user == self.owner)); end
  def destroyable_by?(user = nil); ((!user.nil? && user != :false) && user.admin?); end
  def publishable_by?(user); ((!user.nil? && user != :false) && (user.admin? || user.publisher?));  end
end