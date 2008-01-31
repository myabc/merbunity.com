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
    
    @person = Person.new(valid_person_hash)
    @person.save
    @person.activate
    
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
  end
  
  it "should be a valid cast" do
    @cast.save
    @cast.errors.should have(0).items   
  end
  
  it "should belong to an person" do
    @cast.should respond_to(:person)    
  end
  
  it "should be invalid without an person" do
    cast = Cast.new(valid_cast_hash.without(:person))
    cast.save
    cast.errors.should have(1).item
    cast.errors.on(:person).should_not be_empty
  end
  
  it "should be pending when the person is not a publisher" do
    @cast.person = @person
    @cast.save
    @cast.should be_pending    
    @cast.should_not be_published
  end
  
  it "should not be pending when the person is a publisher" do
    @cast.person = @publisher
    @cast.save
    @cast.should_not be_pending
    @cast.should be_published  
  end
  
  it "should allow itself to be published" do
    @cast.person = @person
    @cast.save
    @cast.publish!
    @cast.should be_published
  end
  
  it "should persist the fact that it's published" do
    @cast.person = @person
    @cast.publish!
    @cast.save
    @cast.reload!
    @cast.should be_published    
  end
    
  it "should be editable by the owner" do
    @cast.person = @person
    @cast.should be_editable_by(@person)
  end
  
  it "should be editable by a publisher" do
    @cast.person = @person
    @cast.should be_editable_by(@publisher)
  end
  
  it "should not be editable by an owner that is not the person or a publisher" do
    @cast.person = @person
    person = Person.new(valid_person_hash.with(:login => "not normal"))
    @cast.should_not be_editable_by(person)
  end  
end

describe Cast, "cast_number" do
  
  before(:each) do
    Cast.auto_migrate!
    @hash1 = valid_cast_hash
    @hash2 = valid_cast_hash
    @cast1 = Cast.new(@hash1)
    @cast2 = Cast.new(@hash2)
    @person = Person.new(valid_person_hash)
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

describe Cast, "Class Methods" do
  
  before(:each) do
    Cast.auto_migrate!
    1.upto(3) do
      c = Cast.new(valid_cast_hash)
      c.publish!
      c.save
    end
    
    1.upto(5) do
      c = Cast.new(valid_cast_hash)
      c.save
    end
  end
  
  it "should get all pending casts" do
    Cast.pending.should have(5).items
  end
  
  it "should get all published casts" do
    Cast.published.should have(3).items
  end
  
end

