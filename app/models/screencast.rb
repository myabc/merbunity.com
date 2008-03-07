class Screencast < DataMapper::Base
  
  include Merbunity::Permissions::ProtectedModel
  
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :size,                     :integer
  property :original_filename,        :string
  property :created_at,               :datetime
  
  belongs_to :owner, :class_name => "Person"
  
  validates_each :uploaded_file,:groups => [:create], :logic => lambda{
      errors.add(:video_file, "There is no video file uploaded") if uploaded_file.blank?
     }
  
  validates_presence_of   :owner, :groups => [:create]

  after_create    :save_file_to_os
  after_destroy   :delete_associated_file!
  
  def initialize(hash = {})
    super(hash)
    if hash[:uploaded_file]
      @original_filename = hash[:uploaded_file]["filename"]
      @tmp_file = hash[:uploaded_file]["tempfile"]
      @size = hash[:uploaded_file]["size"]
    end
  end
  
  def filename
    return nil unless @id && original_filename
    "#{@id}_#{original_filename}"
  end
  
  def file_path
    Merb.root / "screencasts" / "#{self.created_at.year}" / "#{self.created_at.month}"
  end
  
  def full_path
    file_path / filename
  end
  
  
  ################  Published Stuff
  property :published_on,          :datetime
  
  before_create   :set_initial_published_status
  
  def self.pending(opts={})
    self.all(opts.merge!(:published_on => nil))
  end
  
  def self.published(opts={})
    self.all(opts.merge!(:published_on.not => nil))
  end
  
  def pending?
    @published_on.nil?
  end
  
  def published?
    !@published_on.nil?
  end
  
  def publish!
    self.send(:set_publish_data)
    save
  end
  
  private 
  def set_publish_data
    @published_on = DateTime.now
  end
  
  def set_initial_published_status
    self.send(:set_publish_data) if self.owner.publisher?
  end
  
  def delete_associated_file!
    FileUtils.rm(full_path) if File.file?(full_path)
  end
  
  def save_file_to_os
    FileUtils.mkdir_p(file_path)
    FileUtils.copy tmp_file.path, (full_path)
  end
  

  
end