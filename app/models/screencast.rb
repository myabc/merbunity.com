class Screencast
  include DataMapper::Resource
  include Merbunity::WhistlerHelpers::DataMapper
  
  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable
  is_commentable :published, :pending
  
  
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :id,                       Integer,  :serial => true
  property :title,                    String,   :nullable => false
  property :description,              String,   :nullable => false
  property :body,                     DataMapper::Types::Text, :nullable => false
  property :size,                     Integer
  property :original_filename,        String
  property :content_type,             String
  property :download_count,           Integer
  
  whistler_properties :title, :body, :description
  validates_with_method :valid_upload?
  
  
  before :save,     :check_for_updated_file
  after  :save,     :save_file_to_os
  after  :destroy,  :delete_associated_file!

  
  def initialize(hash = {})
    hash = hash.nil? ? {} : hash
    @download_count ||= 0
    super(hash)
    if hash[:uploaded_file]
      setup_screencast_file_from_upload
    end
  end
  
  def filename
    return nil unless @id && original_filename
    "#{@id}_#{original_filename}"
  end
  
  def file_path
    Merb.root / relative_path
  end
  
  def relative_path
    "screencasts" / "#{self.created_at.year}" / "#{self.created_at.month}"
  end
  
  def full_path
    file_path / filename
  end
  
  def display_body
    return "" if self.body.nil?
    @_display_body ||= RedCloth.new(self.body.gsub(/<code.*?<\/code>/mi){|s| s.gsub(/&lt;/,"<")}).to_html
  end
  
  private 
  def delete_associated_file!
    FileUtils.rm(full_path) if File.file?(full_path)
  end
  
  def save_file_to_os
    FileUtils.mkdir_p(file_path)
    FileUtils.copy tmp_file.path, (full_path)
    FileUtils.chmod(0744, full_path)
  end
  
  def check_for_updated_file
    if !self.new_record? && !self.uploaded_file.nil?
      FileUtils.mv(full_path, "#{full_path}_old")
      setup_screencast_file_from_upload
      save_file_to_os
    end
  end
  
  def setup_screencast_file_from_upload
    self.original_filename = self.uploaded_file["filename"]
    @tmp_file = self.uploaded_file["tempfile"]
    self.size = self.uploaded_file["size"]
    self.content_type = self.uploaded_file["content_type"]
  end
  
  def valid_upload?
    if new_record?
      return [false, "There is no video file uploaded"] if uploaded_file.blank?
      return [false, "Only Video files are allowed"]  if !uploaded_file.blank? && self.content_type !~ /video/
    end
    true
  end


  
end