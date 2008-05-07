class Tutorial < DataMapper::Base
  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable
  is_commentable :published, :pending
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :created_at,               :datetime
  property :updated_at,               :datetime
  
  whistler_properties :title, :body, :description
  
  validates_presence_of :title, :description, :body
  
  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body).to_html
  end
end