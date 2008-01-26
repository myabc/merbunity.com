class Cast < DataMapper::Base
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :size,                     :integer
  property :original_filename,        :string
  property :created_at,               :datetime
  property :published_since,                  :datetime

  validates_presence_of   :uploaded_file, :original_filename, :tmp_file, :groups => [:create]
  validates_presence_of   :author, :groups => [:create]

  before_create   :set_initial_published_status
  after_create    :save_file_to_os
  
  belongs_to :author

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
  
  def pending?
    @published_since.nil?
  end
  
  def published?
    !@published_since.nil?
  end
  
  def publish!
    @published_since = DateTime.now
  end
  
  def editable_by?(author)
    (author.publisher? || self.author == author) ? true : false
  end
  
  private 
  def save_file_to_os
    FileUtils.mkdir_p(file_path)
    File.copy tmp_file.path, (file_path / filename)
  end
  
  def set_initial_published_status
    @published_since = DateTime.now if self.author.publisher?
  end
end

