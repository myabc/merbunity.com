class Cast < DataMapper::Base
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :size,                     :integer
  property :original_filename,        :string
  property :created_at,               :datetime
  property :published_since,          :datetime
  property :cast_number,              :integer

  belongs_to :person, :class => "Person" 

  validates_each :uploaded_file,:groups => [:create], :logic => lambda{
      errors.add(:video_file, "There is no video file uploaded") if uploaded_file.blank?
     }
  
  validates_presence_of   :person, :groups => [:create]

  before_create   :set_initial_published_status
  after_create    :save_file_to_os
  after_destroy   :delete_associated_file!
  
  def self.pending(opts={})
    self.all(opts.merge!(:published_since => nil))
  end
  
  def self.published(opts={})
    self.all(opts.merge!(:published_since.not => nil))
  end
    

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
    Merb.root / "casts" / "#{created_at.year}" / "#{created_at.month}"
  end
  
  def full_path
    file_path / filename
  end
  
  def pending?
    @published_since.nil?
  end
  
  def published?
    !@published_since.nil?
  end
  
  def publish!
    self.send(:set_publish_data)
    save
  end
  
  def editable_by?(person)
    (person.publisher? || self.person == person) ? true : false
  end
  
  def destroyable_by?(person)
    (person.publisher? || self.person == person) ? true : false
  end
  
  
  private 
  def set_publish_data
    @published_since = DateTime.now
    
    # setup the cast number
    max = Cast.max(:cast_number) || 0
    @cast_number = max.succ
  end
  
  def delete_associated_file!
    FileUtils.rm(full_path) if File.file?(full_path)
  end
  
  def save_file_to_os
    FileUtils.mkdir_p(file_path)
    File.copy tmp_file.path, (full_path)
  end
  
  def set_initial_published_status
    self.send(:set_publish_data) if self.person.publisher?
  end
end

