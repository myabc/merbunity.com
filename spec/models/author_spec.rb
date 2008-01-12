require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "author_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe Author, "in merbcasts" do
  include AuthorSpecHelper
  
  before(:each) do
    Author.auto_migrate!
    AuthorMailer.stub!(:activation_notification).and_return(true)
    
    @publisher = Author.new(valid_author_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
  end
  
  it "should have many casts" do
    author = Author.new(valid_author_hash)
    author.should respond_to(:casts)
  end
  
  it "should be made a publisher" do
    hash = valid_author_hash
    author = Author.new(hash)
    author.save
    author.activate
    author.should be_active
    author.make_publisher!
    author.should be_publisher    
  end
  
  it "should persist the publisher status" do
    @publisher.should be_publisher
    publisher = Author.first_publisher(:login => @publisher.login)
    publisher.should_not be_nil
    publisher.should be_publisher
  end
  
  it "should not say that an author is a publisher if they have not yet been made a publisher" do
    author = Author.new(hash)
    author.save
    author.activate
    author.should_not be_publisher
  end
  
end
  

describe Author do
  include AuthorSpecHelper
  
  before(:each) do
    Author.clear_database_table
    AuthorMailer.stub!(:activation_notification).and_return(true)
  end

  it "should have a login field" do
    author = Author.new
    author.should respond_to(:login)
    author.valid?
    author.errors.on(:login).should_not be_nil
  end
  
  it "should fail login if there are less than 3 chars" do
    author = Author.new
    author.login = "AB"
    author.valid?
    author.errors.on(:login).should_not be_nil
  end
  
  it "should not fail login with between 3 and 40 chars" do
    author = Author.new
    [3,40].each do |num|
      author.login = "a" * num
      author.valid?
      author.errors.on(:login).should be_nil
    end
  end
  
  it "should fail login with over 90 chars" do
    author = Author.new
    author.login = "A" * 41
    author.valid?
    author.errors.on(:login).should_not be_nil    
  end
  
  it "should make a valid author" do
    author = Author.new(valid_author_hash)
    author.save
    author.errors.should be_empty
    
  end
  
  it "should make sure login is unique" do
    author = Author.new( valid_author_hash.with(:login => "Daniel") )
    author2 = Author.new( valid_author_hash.with(:login => "Daniel"))
    author.save.should be_true
    author.login = "Daniel"
    author2.save.should be_false
    author2.errors.on(:login).should_not be_nil
  end
  
  it "should make sure login is unique regardless of case" do
    Author.find_with_conditions(:login => "Daniel").should be_nil
    author = Author.new( valid_author_hash.with(:login => "Daniel") )
    author2 = Author.new( valid_author_hash.with(:login => "daniel"))
    author.save.should be_true
    author.login = "Daniel"
    author2.save.should be_false
    author2.errors.on(:login).should_not be_nil
  end
  
  it "should downcase logins" do
    author = Author.new( valid_author_hash.with(:login => "DaNieL"))
    author.login.should == "daniel"    
  end  
  
  it "should authenticate a author using a class method" do
    hash = valid_author_hash
    author = Author.new(hash)
    author.save
    author.activate
    author.should_not be_new_record
    Author.authenticate(hash[:login], hash[:password]).should_not be_nil
  end
  
  it "should not authenticate a author using the wrong password" do
    author = Author.new(valid_author_hash)  
    author.save
  
    author.activate
    Author.authenticate(valid_author_hash[:login], "not_the_password").should be_nil
  end
  
  it "should not authenticate a author using the wrong login" do
    author = Author.create(valid_author_hash)  
  
    author.activate
    Author.authenticate("not_the_login", valid_author_hash[:password]).should be_nil
  end
  
  it "should not authenticate a author that does not exist" do
    Author.authenticate("i_dont_exist", "password").should be_nil
  end
  
 
  it "should send a please activate email" do
    author = Author.new(valid_author_hash)
    AuthorMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :signup_notification
      [:from, :to, :subject].each{ |f| mail_args.keys.should include(f)}
      mail_args[:to].should == author.email
      mailer_params[:author].should == author
    end
    author.save
  end
  
  it "should not send a please activate email when updating" do
    author = Author.new(valid_author_hash)
    author.save
    AuthorMailer.should_not_receive(:signup_notification)
    author.login = "not in the valid hash for login"
    author.save    
  end
  
end

describe Author, "the password fields for Author" do
  include AuthorSpecHelper
  
  before(:each) do
    Author.clear_database_table
    @author = Author.new( valid_author_hash )
    AuthorMailer.stub!(:activation_notification).and_return(true)
  end
  
  it "should respond to password" do
    @author.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @author.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @author.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @author.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    author = Author.new( valid_author_hash.without(:password))
    author.stub!(:password_required?).and_return(true)
    author.valid?
    author.errors.on(:password).should_not be_nil
    author.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    author = Author.new(valid_author_hash)
    author.salt.should be_nil
    author.send(:encrypt_password)
    author.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    author = Author.new(valid_author_hash.without(:password))
    author.save
    author.errors.on(:password).should_not be_nil
    author.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    author = Author.new(valid_author_hash.without(:password_confirmation))
    author.save
    (author.errors.on(:password) || author.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      author = Author.new(valid_author_hash.with(:password => ("a" * num)))
      author.valid?
      author.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      author = Author.new(valid_author_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      author.valid?
      author.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    author = Author.new(valid_author_hash)
    author.save    
    author.should be_authenticated(valid_author_hash[:password])
  end
  
  it "should not require a password when saving an existing author" do
    hash = valid_author_hash
    author = Author.create(hash)
    author = Author.find_with_conditions(:login => hash[:login].downcase)
    author.password.should be_nil
    author.password_confirmation.should be_nil
    author.login = "some_different_login_to_allow_saving"
    (author.save).should be_true
  end
  
end

describe Author, "activation" do
  include AuthorSpecHelper
  
  
  before(:each) do
    Author.clear_database_table
    @author = Author.new(valid_author_hash)
  end
  
  it "should have an activation_code as an attribute" do
    @author.attributes.keys.any?{|a| a.to_s == "activation_code"}.should_not be_nil
  end
  
  it "should create an activation code on create" do
    @author.activation_code.should be_nil    
    @author.save
    @author.activation_code.should_not be_nil
  end
  
  it "should not be active when created" do
    @author.should_not be_activated
    @author.save
    @author.should_not be_activated    
  end
  
  it "should respond to activate" do
    @author.should respond_to(:activate)    
  end
  
  it "should activate a author when activate is called" do
    @author.should_not be_activated
    @author.save
    @author.activate
    @author.should be_activated
    Author.find_with_conditions(:login => @author.login).should be_activated
  end
  
  it "should should show recently activated when the instance is activated" do
    @author.should_not be_recently_activated
    @author.activate
    @author.should be_recently_activated
  end
  
  it "should not show recently activated when the instance is fresh" do
    @author.activate
    login = @author.login
    @author = nil
    Author.find_with_conditions(:login => login).should_not be_recently_activated
  end
  
  it "should send out a welcome email to confirm that the account is activated" do
    @author.save
    AuthorMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :activation_notification
      mail_args.keys.should include(:from)
      mail_args.keys.should include(:to)
      mail_args.keys.should include(:subject)
      mail_args[:to].should == @author.email
      mailer_params[:author].should == @author
    end
    @author.activate
  end
  
end

describe Author, "remember_me" do
  include AuthorSpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    Author.clear_database_table
    @author = Author.new(valid_author_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @author.attributes.keys.any?{|a| a.to_s == "remember_token_expires_at"}.should_not be_nil
  end  
  
  it "should respond to remember_token?" do
    @author.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @author.remember_token_expires_at = DateTime.now + 3600
    @author.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = Time.mktime(2009,12,25)
    @author.remember_me_until(time)
    @author.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = Time.mktime(2009,12,25)
    @author.remember_me_until(time)
    @author.remember_token.should_not be_nil
    @author.save
    Author.find_with_conditions(:login => @author.login).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    today = Time.now
    remember_until = today + (2* Merb::Const::WEEK)
    @author.remember_me_for( Merb::Const::WEEK * 2)
    @author.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    @author.remember_me
    @author.remember_token_expires_at.should == (Time.now + (2 * Merb::Const::WEEK ))
  end
  
  it "should forget me" do
    @author.remember_me
    @author.save
    @author.forget_me
    @author.remember_token.should be_nil
    @author.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @author.remember_me
    @author.save
    
    @author = Author.find_with_conditions(:login => @author.login)
    @author.remember_token.should_not be_nil
    
    @author.forget_me

    @author = Author.find_with_conditions(:login => @author.login)
    @author.remember_token.should be_nil
    @author.remember_token_expires_at.should be_nil
  end
  
end