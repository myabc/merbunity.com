require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Cast do
  
  before do
    @cast = Cast.new(valid_cast_hash)
  end
  
  after do
    if File.exists?( Merb.root / "casts")
      FileUtils.rm_rf(Merb.root / "casts")
    end
  end

  it "should be valid" do
    @cast.save
    puts @cast.errors.to_yaml unless @cast.errors.empty?
    @cast.errors.should be_empty
  end
  
  it "should have these attributes" do
    [:title, :body, :description, :original_filename, :size, :created_at].each do |attr|
      @cast.attributes.keys.should include(attr)
    end
  end
  
  it "should respond to uploaded_file" do
    @cast.should respond_to(:uploaded_file)    
  end
  
  it "should requre that uploaded_file be present" do
    cast = Cast.new(valid_cast_hash.except(:uploaded_file))
    cast.save
    cast.errors.on(:uploaded_file).should_not be_nil
  end
  
  it "should set the tmp_file on initialization" do
    hash = valid_cast_hash
    cast = Cast.new(hash)
    cast.tmp_file.path.should == hash[:uploaded_file]["tempfile"].path
  end
  
  it "should set the size on initialization" do
    hash = valid_cast_hash
    cast = Cast.new(hash)    
    cast.size.should == hash[:uploaded_file]["size"]
  end
  
  it "should set the original filename on initialization" do
    hash = valid_cast_hash
    cast = Cast.new(hash)
    cast.original_filename.should == hash[:uploaded_file]["filename"]
  end
  
  it "should set the file_path to MERB_ROOT/year/month" do
    d = Date.today
    @cast.save
    @cast.file_path.should == (Merb.root / "casts" / "#{d.year}" / "#{d.month}" )
  end
  
  it "should save the file in MERB_ROOT/year/month" do
    d = Date.today
    @cast.save
    File.exists?(@cast.file_path).should be_true
  end
  
  it "should save the file with the name id_origianl_filename" do
    d = Date.today
    @cast.save
    File.exists?(@cast.file_path / "#{@cast.id}_#{@cast.original_filename}").should be_true
  end
  
  it "should return nil for filename when there is no id" do
    @cast.should be_new_record
    @cast.filename.should be_nil    
  end
  
  it "should return the id_original_filename for the filename" do
    @cast.save
    @cast.filename.should == "#{@cast.id}_#{@cast.original_filename}"
  end
end

describe Cast, "states" do
  
  before(:each) do
    Cast.auto_migrate!
    @cast = Cast.new(valid_cast_hash)
  end
  
  it "should be a valid cast" do
    @cast.save
    @cast.errors.should have(0).items   
  end
  
  it "should belong to an author" do
    @cast.should respond_to(:author)    
  end
  
  it "should be invalid without an author" do
    cast = Cast.new(valid_cast_hash.without(:author))
    cast.save
    cast.errors.should have(1).item
    cast.errors.on(:author).should_not be_empty
  end
  
  
  
end