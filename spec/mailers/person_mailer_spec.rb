require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe PersonMailer do
  
  def deliver(action, mail_opts= {},opts = {})
    PersonMailer.dispatch_and_deliver action, mail_opts, opts
    @delivery = Merb::Mailer.deliveries.last
  end
  
  before(:each) do
    @u = Person.new(:email => "homer@simpsons.com", :login => "homer", :activation_code => "12345")
    @mailer_params = { :from      => "info@mysite.com",
                       :to        => @u.email,
                       :subject   => "Welcome to MySite.com" }
  end
  
  after(:each) do
    Merb::Mailer.deliveries.clear
  end
  
  it "should send mail to homer@simpsons.com for the signup email" do
    deliver(:signup_notification, @mailer_params, :person => @u)
    @delivery.assigns(:headers).should include("to: homer@simpsons.com")
  end
  
  it "should send the mail from 'info@mysite.com' for the signup email" do
    deliver(:signup_notification, @mailer_params, :person => @u)
    @delivery.assigns(:headers).should include("from: info@mysite.com")
  end
  
  it "should mention the people login in the text signup mail" do
    deliver(:signup_notification, @mailer_params, :person => @u)
    @delivery.text.should include(@u.login)
  end
  # 
  # it "should mention the people login in the HTML signup mail" do
  #   deliver(:signup_notification, @mailer_params, :person => @u)
  #   @delivery.html.should include(@u.login)
  # end
  
  # it "should mention the activation link in the signup emails" do
  #   deliver(:signup_notification, @mailer_params, :person => @u)
  #   the_url = PersonMailer.new.url(:person_activation, :activation_code => @u.activation_code)
  #   the_url.should_not be_nil
  #   @delivery.text.should include( the_url )   
  #   @delivery.html.should include( the_url )
  # end
  
  it "should send mail to homer@simpson.com for the activation email" do
    deliver(:activation_notification, @mailer_params, :person => @u)
    @delivery.assigns(:headers).should include("to: homer@simpsons.com")
  end
  # 
  it "should send the mail from 'info@mysite.com' for the activation email" do
    deliver(:activation_notification, @mailer_params, :person => @u)
    @delivery.assigns(:headers).should include("from: info@mysite.com")    
  end
  
  it "should mention ther people login in the text activation mail" do
    deliver(:activation_notification, @mailer_params, :person => @u)
    @delivery.text.should include(@u.login)
  end

  # it "should mention the suers login in the html activation mail" do
  #   deliver(:activation_notification, @mailer_params, :person => @u)
  #   @delivery.html.should include(@u.login)    
  # end
end