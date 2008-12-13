class Article
  include DataMapper::Resource
  
  property :id,           Serial
  property :type,         Discriminator
  property :title,        String, :length => 255,   :nullable => false
  property :description,  String, :length => 1024,  :nullable => false
  property :slug,         Slug
  property :body,         Text
  property :created_at,   DateTime
  property :created_on,   Date
  property :updated_at,   DateTime
  property :updated_on,   Date
end
