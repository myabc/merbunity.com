class Article
  include DataMapper::Resource
  
  property :id,           Serial
  property :type,         Discriminator
  property :title,        String, :length => 255,     :nullable => false, :unique => true
  property :description,  Text,   :lazy   => false,   :nullable => false
  property :slug,         Slug,   :unique => true,    :nullable => false
  property :body,         Text
  property :created_at,   DateTime
  property :created_on,   Date
  property :updated_at,   DateTime
  property :updated_on,   Date
  
  is_draftable :title, :description, :slug, :body
  
  before(:valid?,   :set_new_slug)
  before(:create,   :set_new_slug)
  before(:publish!, :validate_slug)
  after( :create,   :reload)
  
  belongs_to :owner, :class_name => "User"
  
  private 
  def set_new_slug
    return unless new_record?
    self.slug ||= title
  end
  
  def validate_slug
    errors.add(:slug, "This slug is already in use") if self.class.first(:slug => slug)
  end
    
  
end
