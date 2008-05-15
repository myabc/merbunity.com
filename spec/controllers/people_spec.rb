require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe People do
  
  include PersonSpecHelper
  
  before(:each) do
    Person.clear_database_table
  end
  
  it 'allows signup' do
     lambda do
       controller = create_person
       controller.should redirect      
     end.should change(Person, :count).by(1)
   end

   it 'requires login on signup' do
     lambda do
       controller = create_person(:login => nil)
       controller.assigns(:person).errors.on(:login).should_not be_nil
       controller.should respond_successfully
     end.should_not change(Person, :count)
   end
    
   it 'requires password on signup' do
     lambda do
       controller = create_person(:password => nil)
       controller.assigns(:person).errors.on(:password).should_not be_nil
       controller.should respond_successfully
     end.should_not change(Person, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       controller = create_person(:password_confirmation => nil)
       controller.assigns(:person).errors.on(:password_confirmation).should_not be_nil
       controller.should respond_successfully
     end.should_not change(Person, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       controller = create_person(:email => nil)
       controller.assigns(:person).errors.on(:email).should_not be_nil
       controller.should respond_successfully
     end.should_not change(Person, :count)
   end
   
   it "should have a route for person activation" do
     request_to("/people/activate/1234") do |params|
       params[:controller].should == "People"
       params[:action].should == "activate" 
       params[:activation_code].should == "1234"    
     end
   end

   it 'activates person' do
     controller = create_person(:login => "aaron", :password => "test", :password_confirmation => "test")
     @person = controller.assigns(:person)
     Person.authenticate('aaron', 'test').should be_nil
     controller = get "/people/activate/1234" 
     controller.should redirect_to("/")
   end
     
   def create_person(options = {})
     post "/people", :person => valid_person_hash.merge(options)
   end
end

