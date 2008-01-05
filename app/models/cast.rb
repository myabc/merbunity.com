class Cast < DataMapper::Base
  attr_accessor :uploaded_file
  attr_reader   :tmp_file
  
  property :title,                    :string
  property :description,              :string
  property :body,                     :text
  property :size,                     :integer
  property :original_filename,        :string
  property :created_at,               :datetime
  
  validates_presence_of   :uploaded_file, :original_filename, :tmp_file, :groups => [:create]

  after_create :save_file_to_os

  def initialize(hash = {})
    super(hash)
    if hash[:uploaded_file]
      @original_filename = hash[:uploaded_file]["filename"]
      @tmp_file = hash[:uploaded_file]["tempfile"]
      @size = hash[:uploaded_file]["size"]
    end
  end
  
  def filename
    return nil unless @id
    "#{@id}_#{original_filename}"
  end
  
  def file_path
    MERB_ROOT / "casts" / "#{created_at.year}" / "#{created_at.month}"
  end
  
  private 
  def save_file_to_os
    FileUtils.mkdir_p(file_path)
    File.copy tmp_file.path, (file_path / filename)
  end

end

