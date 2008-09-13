require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Screencast do
  
  before do
    Screencast.auto_migrate!
    @screencast = Screencast.new(valid_screencast_hash)
  end
  
  after do
    if File.exists?( Merb.root / "screencasts")
      FileUtils.rm_rf(Merb.root / "screencasts")
    end
  end
  
  def do_uploaded_file(path)
    out = { :uploaded_file => {}}
    File.open(path) do |f|
      basename = File.basename(f.path)
      mime = MIME::Types.type_for(basename)[0]
      t = Tempfile.new(basename)
      t << f.read
      res = out[:uploaded_file]
      res["content_type"] = mime.content_type
      res["size"]         = t.size
      res["filename"]     = basename
      res["tempfile"]     = t
    end
    out
  end
  
  after do
    @file.close unless @file.nil?
  end

  it "should be valid" do
    @screencast.save
    puts @screencast.errors.to_yaml unless @screencast.errors.empty?
    @screencast.errors.should be_empty
  end
  
  it "should have these attributes" do
    [:title, :body, :description, :original_filename, :size, :created_at].each do |attr|
      @screencast.attributes.keys.should include(attr)
    end
  end
  
  it "should respond to uploaded_file" do
    @screencast.should respond_to(:uploaded_file)    
  end
  
  it "should requre that uploaded_file be present" do
    screencast = Screencast.new(valid_screencast_hash.except(:uploaded_file))
    screencast.save
    screencast.errors.on(:valid_upload?).should_not be_nil
  end
  
  it "should not have an error if the uploaded file has a video mime type" do
    video_file_root = Merb.root / "spec" / "fixtures" / "video_files"
    ["valid_mov_file.mov", "penguin.mpg"].each do |file|
      screencast = Screencast.new(valid_screencast_hash.with(do_uploaded_file(video_file_root / file)))
      screencast.save
      screencast.errors.on(:video_file).should be_nil
    end
  end
  
  it "should have an error if the uploaded file does not have a video mime type" do
    video_file_root = Merb.root / "spec" / "fixtures" / "video_files"
    ["pic.jpg", "text.txt"].each do |file|
      screencast = Screencast.new(valid_screencast_hash.with(do_uploaded_file(video_file_root / file)))
      screencast.save
      screencast.errors.on(:valid_upload?).should_not be_nil
    end
  end
  
  it "should set the tmp_file on initialization" do
    hash = valid_screencast_hash
    screencast = Screencast.new(hash)
    screencast.tmp_file.path.should == hash[:uploaded_file]["tempfile"].path
  end
  
  it "should set the size on initialization" do
    hash = valid_screencast_hash
    screencast = Screencast.new(hash)    
    screencast.size.should == hash[:uploaded_file]["size"]
  end
  
  it "should set the original filename on initialization" do
    hash = valid_screencast_hash
    screencast = Screencast.new(hash)
    screencast.original_filename.should == hash[:uploaded_file]["filename"]
  end
  
  it "should set the file_path to Merb.root/year/month" do
    d = Date.today
    @screencast.save
    @screencast.file_path.should == (Merb.root / "screencasts" / "#{d.year}" / "#{d.month}" )
  end
  
  it "should save the file in Merb.root/year/month" do
    d = Date.today
    @screencast.save
    File.exists?(@screencast.file_path).should be_true
  end
  
  it "should save the file with the name id_origianl_filename" do
    d = Date.today
    @screencast.save
    File.exists?(@screencast.file_path / "#{@screencast.id}_#{@screencast.original_filename}").should be_true
  end
  
  it "should return nil for filename when there is no id" do
    @screencast.should be_new_record
    @screencast.filename.should be_nil    
  end
  
  it "should return the id_original_filename for the filename" do
    @screencast.save
    @screencast.filename.should == "#{@screencast.id}_#{@screencast.original_filename}"
  end
  
  it "should render textile of the body in display body" do
    sc = Screencast.new(valid_screencast_hash.with(:body => "h1. Heading"))
    sc.save
    formatted(sc.body).should have_tag(:h1){|t| t.should contain("Heading")}
  end
  
  it "should change the screencast if a new one is added" do
    video_root = Merb.root / "spec" / "fixtures" / "video_files"
    sc = Screencast.new(valid_screencast_hash.with(do_uploaded_file(video_root / "valid_mov_file.mov")))
    sc.save
    sc.should_not be_new_record
    sc.full_path.should_not be_nil
    File.exists?(sc.full_path).should be_true
    fn = sc.filename
    fp = sc.full_path
    sc.update_attributes(do_uploaded_file(video_root / "penguin.mpg"))
    sc.save
    sc.filename.should_not == fn
    sc.filename.should match(/penguin.mpg$/)
    File.exists?(sc.full_path).should be_true
    File.exists?(fp).should_not be_true
    #rename the file
    File.exists?(fp + "_old").should be_true
  end
  
end

describe Screencast, "states" do
  
  before(:each) do
    Screencast.auto_migrate!
    @screencast = Screencast.new(valid_screencast_hash)
    
    @person = Person.new(valid_person_hash)
    @person.save
    @person.activate
    
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
  end
  
  it "should be a valid screencast" do
    @screencast.save
    @screencast.errors.keys.should have(0).items   
  end
  
  it "should belong to an person" do
    @screencast.should respond_to(:owner)    
  end
  
  it "should be invalid without an person" do
    pending("peding a resolution of the issue on the production server")
    screencast = Screencast.new(valid_screencast_hash.without(:owner))
    screencast.save
    screencast.errors.should have(1).item
    screencast.errors.on(:owner).should_not be_empty
  end

end

describe Screencast, "Class Methods" do
  
  before(:each) do
    Screencast.auto_migrate!
    Person.auto_migrate!
    @pub = Person.create(valid_person_hash)
    @pub.make_publisher!
    1.upto(3) do
      c = Screencast.new(valid_screencast_hash)
      c.publish!(@pub)
      c.save
    end
    
    1.upto(5) do
      c = Screencast.new(valid_screencast_hash)
      c.save
      c.owner.publish(c)
    end
    
    1.upto(6) do
      c = Screencast.new(valid_screencast_hash)
      c.save
    end    
  end
  
  it "should get all pending screencasts" do
    d = Screencast.pending
    d.should have(5).items
    d.all?{|s| s.pending?}
  end
  
  it "should get all published screencasts" do
    d = Screencast.published
    d.should have(3).items
    d.all?{|s| s.published?}
  end
  
  it "should get all draft screencasts" do
    d = Screencast.drafts
    d.should have(6).items   
    d.all?{|s| s.draft?}.should be_true
  end
  
end


