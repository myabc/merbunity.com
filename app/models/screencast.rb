class Screencast < DataMapper::Base
  
  include Merbunity::Permissions::ProtectedModel
  include Merbunity::Publishable
  
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

  after_create    :save_file_to_os
  after_destroy   :delete_associated_file!
  
  def initialize(hash = {})
    hash = hash.nil? ? {} : hash
    if hash[:uploaded_file]
      @original_filename = hash[:uploaded_file]["filename"]
      @tmp_file = hash[:uploaded_file]["tempfile"]
      @size = hash[:uploaded_file]["size"]
      @content_type = hash[:uploaded_file]["content_type"]
    end
    @download_count ||= 0
    super(hash)
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
    @_display_body ||= RedCloth.new(self.body).to_html
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

  
end