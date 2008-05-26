unless defined?(Tutorial)  # WTF DO I HAVE TO TEST THIS!!!
  class Tutorial
    include DataMapper::Resource
    include Merbunity::WhistlerHelpers::DataMapper

    include Merbunity::Permissions::ProtectedModel
    include Merbunity::Publishable

    is_commentable :published, :pending

    property :id,                       Integer,                  :serial => true
    property :title,                    String,                   :nullable => false
    property :description,              String,                   :nullable => false
    property :body,                     DataMapper::Types::Text,  :nullable => false

    whistler_properties :title, :body, :description

    # validates_present :title, :description, :body

    def display_body
      return "" if self.body.nil?
      @_display_body ||= RedCloth.new(self.body.gsub(/<code.*?<\/code>/mi){|s| s.gsub(/&lt;/,"<")}).to_html
    end
  end
end