require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Cast do
  
  before do
    Cast.auto_migrate!
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
    cast.errors.on(:video_file).should_not be_nil
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
    
    @author = Author.new(valid_author_hash)
    @author.save
    @author.activate
    
    @publisher = Author.new(valid_author_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
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
  
  it "should be pending when the author is not a publisher" do
    @cast.author = @author
    @cast.save
    @cast.should be_pending    
    @cast.should_not be_published
  end
  
  it "should not be pending when the author is a publisher" do
    @cast.author = @publisher
    @cast.save
    @cast.should_not be_pending
    @cast.should be_published  
  end
  
  it "should allow itself to be published" do
    @cast.author = @author
    @cast.save
    @cast.publish!
    @cast.should be_published
  end
  
  it "should persist the fact that it's published" do
    @cast.author = @author
    @cast.publish!
    @cast.save
    @cast.reload!
    @cast.should be_published    
  end
    
  it "should be editable by the owner" do
    @cast.author = @author
    @cast.should be_editable_by(@author)
  end
  
  it "should be editable by a publisher" do
    @cast.author = @author
    @cast.should be_editable_by(@publisher)
  end
  
  it "should not be editable by an owner that is not the author or a publisher" do
    @cast.author = @author
    author = Author.new(valid_author_hash.with(:login => "not normal"))
    @cast.should_not be_editable_by(author)
  end  
end

describe Cast, "cast_number" do
  
  before(:each) do
    Cast.auto_migrate!
    @hash1 = valid_cast_hash
    @hash2 = valid_cast_hash
    @cast1 = Cast.new(@hash1)
    @cast2 = Cast.new(@hash2)
    @author = Author.new(valid_author_hash)
  end
  
  it "should not have a cast number when pending" do
    @cast1.save
    @cast1.should be_pending
    @cast1.cast_number.should be_nil
  end
  
  it "should have a cast number when published" do
    @cast1.publish!
    @cast1.should be_published    
    @cast1.cast_number.should == 1
  end
  
  it "should increment the cast number when published" do
    1.upto(12) do |i|
      cast = Cast.new(valid_cast_hash)
      cast.cast_number.should be_nil
      cast.publish!
      cast.cast_number.should == i
    end
  end
  
end

