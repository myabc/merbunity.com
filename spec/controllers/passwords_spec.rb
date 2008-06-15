require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')


describe Passwords do
  
  before(:each) do
    Person.clear_database_table
    @person = Person.create(valid_person_hash.with(
      :password => "test",
      :password_confirmation => "test",
      :login => "gary",
      :email => "gary@example.com"
    ))
    @person.activate
    @deliveries = Merb::Mailer.deliveries
  end
  
  after(:each) do
    Merb::Mailer.deliveries.clear
  end
  
  describe "new" do
    
    it "should render a form to create a reset password" do
      c = dispatch_to(Passwords, :new)
      c.body.should have_tag(:form, :action => url(:passwords), :method => "post")
    end
  end
  
  describe "edit" do
    
    def dispatch_edit(opts = {})
      dispatch_to(Passwords, :edit, opts = {}) do |c|
        c.stub!(:current_person).and_return(@person)
      end
    end
    
    it "should require the user to be logged in" do
      c = dispatch_to(Passwords, :edit)
      c.should redirect_to(url(:login))
    end
    
    it "should have a form that is posted to url(:passwords)" do
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:passwords), :method => "post")
    end
    
    it "the form should have password and confirmation password fields" do
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "person_password")
        d.should have_tag(:input, :type => "password", :id => "person_password_confirmation")
      end
    end
    
    it "should show the old password confirmation box if the user does not have a forgotten password" do
      @person.clear_forgot_password!
      @person.reload
      @person.should_not have_forgotten_password
      
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "person_password")
        d.should have_tag(:input, :type => "password", :id => "person_password_confirmation")
        d.should have_tag(:input, :type => "password", :name => "current_password")
      end
    end
    
    it "should not show the old password ocnfirmation box if the user does have a forgotten password" do
      @person.forgot_password!
      @person.reload
      
      c = dispatch_edit
      c.body.should have_tag(:form, :action => url(:passwords), :method => "post") do |d|
        d.should have_tag(:input, :type => "hidden", :name => "_method")
        d.should have_tag(:input, :type => "password", :id => "person_password")
        d.should have_tag(:input, :type => "password", :id => "person_password_confirmation")
        d.should_not have_tag(:input, :type => "password", :name => "current_password")
      end
    end
  end
  
  describe "create" do
    def dispatch_create(opts = {})
      dispatch_to(Passwords, :create, {:email => @person.email}.merge!(opts) )
    end
    
    it "should set the persons password to forgotten" do
      @person.should_not have_forgotten_password
      dispatch_create
      @person.reload
      @person.should have_forgotten_password
    end
    
    it "should only change the person who's email was sent" do
      person = Person.create(valid_person_hash)
      person.should_not be_new_record
      
      @person.should_not have_forgotten_password
      person.should_not have_forgotten_password
      
      dispatch_create(:email => person.email)
      
      person.reload
      @person.reload
      
      @person.should_not have_forgotten_password
      person.should have_forgotten_password
    end
    
    it "should redirect" do
      c = dispatch_create
      c.should redirect
    end
    
    it "should raise an unauthorized if the user is logged in, and not the owner of the email" do
      person = Person.create(valid_person_hash)
      lambda do
        c = dispatch_to(Passwords, :create, :email => person.email) do |c|
          c.stub!(:current_person).and_return(@person)
        end
      end.should raise_error(Merb::Controller::Unauthorized)
    end
    
    it "should raise a NotFound error if the persons email does not exist" do
      lambda do
        c = dispatch_create(:email => "does_not_exist@blah.com")
      end.should raise_error(Merb::Controller::NotFound)
    end
    
    it "should send a notification email that the password is to be resent" do
      c = dispatch_create
      c.should redirect_to("/")
      @person.reload
      @deliveries.last.should_not be_nil
      @deliveries.last.text.should include("http://merbunity.com#{url(:passwords, @person.password_reset_key)}")
    end
  end
  
  describe "show" do
    
    def dispatch_show(opts = {})
      dispatch_to(Passwords, :show, opts)
    end
    
    it "should redirect to edit if given a valid reset key" do
      @person.forgot_password!
      c = dispatch_show(:id => @person.password_reset_key)
      c.should redirect_to(url(:edit_password_form))
    end
    
    it "should redirect to home if given an invalid reset key" do
      c = dispatch_show(:id => "11234")
      c.should redirect_to("/")
    end
    
    it "should log the user in" do
      @person.forgot_password!
      c = dispatch_show(:id => @person.password_reset_key)
      @person.reload
      c.should be_logged_in
      c.send(:current_person).should == @person
    end
  end
  
  describe "update" do
    
    def dispatch_update(opts = {})
      dispatch_to(Passwords, :update, opts){|c| c.stub!(:current_person).and_return(@person)}
    end
    
    it "should require the user to be logged in" do
      c = dispatch_to(Passwords, :update)
      c.should redirect_to(url(:login))
    end
    
    it "should update the current_users password with pw and pw conf if there is a password_reset_key present" do
      @person.forgot_password!
      @person.password_reset_key.should_not be_nil
      c = dispatch_update(:person => {:password => "gahh", :password_confirmation => "gahh"})
      @person.reload 
      Person.authenticate(@person.login, "gahh").should == @person      
    end
    
    it "should change the password when given a current password if there is no password_reset_key present" do
      @person.should_not have_forgotten_password
      c = dispatch_update(:person => {:password => "gahh", :password_confirmation => "gahh"}, :current_password => "test")
      @person.reload
      Person.authenticate(@person.login, "gahh").should == @person
    end
    
    it "should not change the password when not given a current password if there is no password_reset_key present" do
      @person.should_not have_forgotten_password?
      c = dispatch_update(:person => {:password => "gahh", :password_confirmation => "gahh"})
      @person.reload
      Person.authenticate(@person.login, "gahh").should be_nil
      Person.authenticate(@person.login, "test").should == @person
    end
    
    it "should not change the password when the current password is wrong" do
      @person.should_not have_forgotten_password?
      c = dispatch_update(:person => {:password => "gahh", :password_confirmation => "gahh"}, :current_password => "wrong")
      @person.reload
      Person.authenticate(@person.login, "wrong").should be_nil
      Person.authenticate(@person.login, "test").should == @person
    end
    
    it "should clear the password_reset_key" do
      @person.forgot_password!
      @person.should have_forgotten_password
      dispatch_update(:person => {:password => "gahh", :password_confirmation => "gahh"})
      @person.reload
      @person.should_not have_forgotten_password
    end
    
    it "should redirect to edit back to edit if the passwords do not match and not delete the forgotten password" do
      @person.forgot_password!
      c = dispatch_update(:person => {:password => "blah", :password_confirmation => "foo"})
      @person.reload
      Person.authenticate(@person.login, "blah").should be_nil
      c.should redirect_to(url(:edit_password_form))
      @person.should have_forgotten_password
    end
    
    it "should redirect to home if the password was changed" do
      @person.forgot_password!
      c = dispatch_update(:person => {:password => "blah", :password_confirmation =>"blah"})
      @person.reload
      Person.authenticate(@person.login, "blah").should_not be_nil
      c.should redirect_to("/")
    end
  end
  
end