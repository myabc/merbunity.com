class Screencast < DataMapper::Base
  
  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable
  is_commentable :published, :pending
  
  
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :size,                     :integer
  property :original_filename,        :string
  property :content_type,             :string
  property :created_at,               :datetime
  property :updated_at,               :datetime
  property :download_count,           :integer
  
  whistler_properties :title, :body, :description
  validates_presence_of :title, :description, :body
  
  validates_each :uploaded_file,:groups => [:create], :logic => lambda{
      errors.add(:video_file, "There is no video file uploaded") if uploaded_file.blank?
      errors.add(:video_file, "Only Video files are allowed") if !uploaded_file.blank? && self.content_type !~ /video/
     }

  after_create      :save_file_to_os
  after_destroy     :delete_associated_file!
  before_validation :check_for_updated_file
  
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

  
end