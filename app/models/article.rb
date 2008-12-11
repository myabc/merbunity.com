class Article
  include DataMapper::Resource
  include DataMapper::Timestamp

  property :id,           Integer, :serial => true
  property :type,         Discriminator
  property :title,        String, :length => 255
  property :description,  String, :length => 1024
  property :slug,         Slug
  property :body,         Text
  property :created_at,   DateTime
  property :created_on,   Date
  property :updated_at,   DateTime
  property :updated_on,   Date
end
