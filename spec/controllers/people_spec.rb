require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "person_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe People do
  
  include PersonSpecHelper
  
  before(:each) do
    Person.clear_database_table
  end
  
  it 'allows signup' do
     lambda do
       create_person
       controller.should redirect      
     end.should change(Person, :count).by(1)
   end

   it 'requires login on signup' do
     lambda do
       create_person(:login => nil)
       controller.assigns(:person).errors.on(:login).should_not be_nil
       controller.should be_successful
     end.should_not change(Person, :count)
   end
    
   it 'requires password on signup' do
     lambda do
       create_person(:password => nil)
       controller.assigns(:person).errors.on(:password).should_not be_nil
       controller.should be_successful
     end.should_not change(Person, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       create_person(:password_confirmation => nil)
       controller.assigns(:person).errors.on(:password_confirmation).should_not be_nil
       controller.should be_successful
     end.should_not change(Person, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       create_person(:email => nil)
       controller.assigns(:person).errors.on(:email).should_not be_nil
       controller.should be_successful
     end.should_not change(Person, :count)
   end
   
   it "should have a route for person activation" do
     with_route("/people/activate/1234") do |params|
       params[:controller].should == "People"
       params[:action].should == "activate" 
       params[:activation_code].should == "1234"    
     end
   end

   it 'activates person' do
     create_person(:login => "aaron", :password => "test", :password_confirmation => "test")
     @person = controller.assigns(:person)
     Person.authenticate('aaron', 'test').should be_nil
     get "/people/activate/1234" 
     controller.should redirect_to("/")
   end

   it 'does not activate person without key' do
       get "/people/activate"
       controller.should be_missing
   end
     
   def create_person(options = {})
     post "/people", :person => valid_person_hash.merge(options)
   end
end