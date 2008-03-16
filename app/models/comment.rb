class Comment < DataMapper::Base
  
  property :body,       :string
  property :created_at, :datetime
  
  belongs_to :owner, :class => "Person"
  
  validates_presence_of :owner, :groups => :create
  
end