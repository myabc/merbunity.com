unless defined?(Tutorial)
class Tutorial
  include DataMapper::Resource
  include Merbunity::WhistlerHelpers::DataMapper

  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable

  # Commentable stuff
    has n, :comments_tutorials, :class_name => "CommentsTutorials"
    has n, :comments,         :through => :comments_tutorials, Comment.status => "published" 
    has n, :pending_comments, :through => :comments_tutorials, Comment.status => "pending", :class_name => "Comment"
  
  property :id,                       Integer,                  :serial => true
  property :title,                    String,                   :nullable => false
  property :description,              String,                   :nullable => false
  property :body,                     DataMapper::Types::Text,  :nullable => false
  property :comment_count,            Integer,  :nullable => false, :default => 0

  whistler_properties :title, :body, :description

  # validates_present :title, :description, :body

  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body.gsub(/<code.*?<\/code>/mi){|s| s.gsub(/&lt;/,"<")}).to_html
  end
end
end
