class Comment
  include DataMapper::Resource
  
  include Merbunity::WhistlerHelpers::DataMapper
  
  property :id,         Integer, :serial => true
  property :body,       String
  property :created_at, DateTime
  
  belongs_to :owner, :class_name => "Person"
  
  validates_present :owner, :groups => :create
  
  whistler_properties :body

end