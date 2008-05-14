require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Person, "in merbunity" do
  include PersonSpecHelper
  
  before(:each) do
    Person.auto_migrate!
    PersonMailer.stub!(:activation_notification).and_return(true)
    
    @publisher = Person.new(valid_person_hash)
    @publisher.save
    @publisher.activate
    @publisher.make_publisher!
    
    @person = Person.new(valid_person_hash)
    @person.save
  end
  
  it "should set published_item_count to 0 by default" do
    @person.published_item_count.should == 0    
  end
  
  it "should have many screencasts" do
    person = Person.new(valid_person_hash)
    person.should respond_to(:screencasts)
  end
  
  it "should be made a publisher" do
    hash = valid_person_hash
    person = Person.new(hash)
    person.save
    person.activate
    person.should be_active
    person.make_publisher!
    person.should be_publisher    
  end
  
  it "should persist the publisher status" do
    @publisher.should be_publisher
    publisher = Person.first_publisher(:login => @publisher.login)
    publisher.should_not be_nil
    publisher.should be_publisher
  end
  
  it "should not say that an person is a publisher if they have not yet been made a publisher" do
    person = Person.new(hash)
    person.save
    person.activate
    person.should_not be_publisher
  end
  
  it "should have a publish method that tells the obj to publish" do
    person = Person.new(hash)    
    person.save
    person.activate
    person.make_publisher!
    obj = mock("Publishable object")
    obj.should_receive(:publishable_by?).with(person).and_return true
    obj.should_receive(:publish!).with(person).and_return true
    person.publish(obj)
  end
  
  it "should return true for can_edit? if there is no editable_by? method on the target" do
    obj = Object.new
    obj.should_not respond_to(:editable_by?)
    @person.can_edit?(obj).should be_true
  end
  
  class EditableTest
    def initialize(value)
      @response = value
    end
    def editable_by?(user)
      @response
    end
  end
  
  it "should return the value of :editable_by? if it responds to it" do
    @person.can_edit?(EditableTest.new(true)).should be_true
    @person.can_edit?(EditableTest.new(false)).should be_false    
  end
  
  it "should have an attribute_to method" do
    @person.attribute_to.should == @person.login
  end
  
end


describe Person do
  include PersonSpecHelper
  
  before(:each) do
    Person.clear_database_table
    PersonMailer.stub!(:activation_notification).and_return(true)
  end

  it "should have a login field" do
    person = Person.new
    person.should respond_to(:login)
    person.valid?
    person.errors.on(:login).should_not be_nil
  end
  
  it "should fail login if there are less than 3 chars" do
    person = Person.new
    person.login = "AB"
    person.valid?
    person.errors.on(:login).should_not be_nil
  end
  
  it "should not fail login with between 3 and 40 chars" do
    person = Person.new
    [3,40].each do |num|
      person.login = "a" * num
      person.valid?
      person.errors.on(:login).should be_nil
    end
  end
  
  it "should fail login with over 90 chars" do
    person = Person.new
    person.login = "A" * 41
    person.valid?
    person.errors.on(:login).should_not be_nil    
  end
  
  it "should make a valid person" do
    person = Person.new(valid_person_hash)
    person.save
    person.errors.should be_empty
    
  end
  
  it "should make sure login is unique" do
    person = Person.new( valid_person_hash.with(:login => "Daniel") )
    person2 = Person.new( valid_person_hash.with(:login => "Daniel"))
    person.save.should be_true
    person.login = "Daniel"
    person2.save.should be_false
    person2.errors.on(:login).should_not be_nil
  end
  
  it "should make sure login is unique regardless of case" do
    Person.find_with_conditions(:login => "Daniel").should be_nil
    person = Person.new( valid_person_hash.with(:login => "Daniel") )
    person2 = Person.new( valid_person_hash.with(:login => "daniel"))
    person.save.should be_true
    person.login = "Daniel"
    person2.save.should be_false
    person2.errors.on(:login).should_not be_nil
  end
  
  it "should downcase logins" do
    person = Person.new( valid_person_hash.with(:login => "DaNieL"))
    person.login.should == "daniel"    
  end  
  
  it "should authenticate a person using a class method" do
    hash = valid_person_hash
    person = Person.new(hash)
    person.save
    person.activate
    person.should_not be_new_record
    Person.authenticate(hash[:login], hash[:password]).should_not be_nil
  end
  
  it "should not authenticate a person using the wrong password" do
    person = Person.new(valid_person_hash)  
    person.save
  
    person.activate
    Person.authenticate(valid_person_hash[:login], "not_the_password").should be_nil
  end
  
  it "should not authenticate a person using the wrong login" do
    person = Person.create(valid_person_hash)  
  
    person.activate
    Person.authenticate("not_the_login", valid_person_hash[:password]).should be_nil
  end
  
  it "should not authenticate a person that does not exist" do
    Person.authenticate("i_dont_exist", "password").should be_nil
  end
  
 
  it "should send a please activate email" do
    person = Person.new(valid_person_hash)
    PersonMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :signup_notification
      [:from, :to, :subject].each{ |f| mail_args.keys.should include(f)}
      mail_args[:to].should == person.email
      mailer_params[:person].should == person
    end
    person.save
  end
  
  it "should not send a please activate email when updating" do
    person = Person.new(valid_person_hash)
    person.save
    PersonMailer.should_not_receive(:signup_notification)
    person.login = "not in the valid hash for login"
    person.save    
  end
  
end

describe Person, "the password fields for Person" do
  include PersonSpecHelper
  
  before(:each) do
    Person.clear_database_table
    @person = Person.new( valid_person_hash )
    PersonMailer.stub!(:activation_notification).and_return(true)
  end
  
  it "should respond to password" do
    @person.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @person.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @person.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @person.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    person = Person.new( valid_person_hash.without(:password))
    person.stub!(:password_required?).and_return(true)
    person.valid?
    person.errors.on(:password).should_not be_nil
    person.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    person = Person.new(valid_person_hash)
    person.salt.should be_nil
    person.send(:encrypt_password)
    person.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    person = Person.new(valid_person_hash.without(:password))
    person.save
    person.errors.on(:password).should_not be_nil
    person.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    person = Person.new(valid_person_hash.without(:password_confirmation))
    person.save
    (person.errors.on(:password) || person.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      person = Person.new(valid_person_hash.with(:password => ("a" * num)))
      person.valid?
      person.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      person = Person.new(valid_person_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      person.valid?
      person.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    person = Person.new(valid_person_hash)
    person.save    
    person.should be_authenticated(valid_person_hash[:password])
  end
  
  it "should not require a password when saving an existing person" do
    hash = valid_person_hash
    person = Person.create(hash)
    person = Person.find_with_conditions(:login => hash[:login].downcase)
    person.password.should be_nil
    person.password_confirmation.should be_nil
    person.login = "some_different_login_to_allow_saving"
    (person.save).should be_true
  end
  
end

describe Person, "activation" do
  include PersonSpecHelper
  
  
  before(:each) do
    Person.clear_database_table
    @person = Person.new(valid_person_hash)
  end
  
  it "should have an activation_code as an attribute" do
    @person.attributes.keys.any?{|a| a.to_s == "activation_code"}.should_not be_nil
  end
  
  it "should create an activation code on create" do
    @person.activation_code.should be_nil    
    @person.save
    @person.activation_code.should_not be_nil
  end
  
  it "should not be active when created" do
    @person.should_not be_activated
    @person.save
    @person.should_not be_activated    
  end
  
  it "should respond to activate" do
    @person.should respond_to(:activate)    
  end
  
  it "should activate a person when activate is called" do
    @person.should_not be_activated
    @person.save
    @person.activate
    @person.should be_activated
    Person.find_with_conditions(:login => @person.login).should be_activated
  end
  
  it "should should show recently activated when the instance is activated" do
    @person.should_not be_recently_activated
    @person.activate
    @person.should be_recently_activated
  end
  
  it "should not show recently activated when the instance is fresh" do
    @person.activate
    login = @person.login
    @person = nil
    Person.find_with_conditions(:login => login).should_not be_recently_activated
  end
  
  it "should send out a welcome email to confirm that the account is activated" do
    @person.save
    PersonMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :activation_notification
      mail_args.keys.should include(:from)
      mail_args.keys.should include(:to)
      mail_args.keys.should include(:subject)
      mail_args[:to].should == @person.email
      mailer_params[:person].should == @person
    end
    @person.activate
  end
  
  it {@person.should respond_to(:admin?)}

  it "should report true to the admin? question if the admin_since property is set" do
    p = Person.create(valid_person_hash)
    p.make_admin!
    p.should be_admin
  end
  
  it "should return false if the admin_since property is not set" do
    p = Person.create(valid_person_hash)
    p.admin_since = nil
    p.save
    p.admin_since.should be_nil
    p.should_not be_admin
  end
end

describe Person, "remember_me" do
  include PersonSpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    Person.clear_database_table
    @person = Person.new(valid_person_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @person.attributes.keys.any?{|a| a.to_s == "remember_token_expires_at"}.should_not be_nil
  end  
  
  it "should respond to remember_token?" do
    @person.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @person.remember_token_expires_at = DateTime.now + 3600
    @person.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = Time.mktime(2009,12,25)
    @person.remember_me_until(time)
    @person.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = Time.mktime(2009,12,25)
    @person.remember_me_until(time)
    @person.remember_token.should_not be_nil
    @person.save
    Person.find_with_conditions(:login => @person.login).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    today = Time.now
    remember_until = today + (2* Merb::Const::WEEK)
    @person.remember_me_for( Merb::Const::WEEK * 2)
    @person.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = Time.now
    Time.stub!(:now).and_return(t)
    @person.remember_me
    @person.remember_token_expires_at.should == (Time.now + (2 * Merb::Const::WEEK ))
  end
  
  it "should forget me" do
    @person.remember_me
    @person.save
    @person.forget_me
    @person.remember_token.should be_nil
    @person.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @person.remember_me
    @person.save
    
    @person = Person.find_with_conditions(:login => @person.login)
    @person.remember_token.should_not be_nil
    
    @person.forget_me

    @person = Person.find_with_conditions(:login => @person.login)
    @person.remember_token.should be_nil
    @person.remember_token_expires_at.should be_nil
  end
  
end