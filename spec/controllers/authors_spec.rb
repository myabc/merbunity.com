require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "author_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe Authors do
  
  include AuthorSpecHelper
  
  before(:each) do
    Author.clear_database_table
  end
  
  it 'allows signup' do
     lambda do
       create_author
       controller.should redirect      
     end.should change(Author, :count).by(1)
   end

   it 'requires login on signup' do
     lambda do
       create_author(:login => nil)
       controller.assigns(:author).errors.on(:login).should_not be_nil
       controller.should be_successful
     end.should_not change(Author, :count)
   end
    
   it 'requires password on signup' do
     lambda do
       create_author(:password => nil)
       controller.assigns(:author).errors.on(:password).should_not be_nil
       controller.should be_successful
     end.should_not change(Author, :count)
   end
     
   it 'requires password confirmation on signup' do
     lambda do
       create_author(:password_confirmation => nil)
       controller.assigns(:author).errors.on(:password_confirmation).should_not be_nil
       controller.should be_successful
     end.should_not change(Author, :count)
   end
   
   it 'requires email on signup' do
     lambda do
       create_author(:email => nil)
       controller.assigns(:author).errors.on(:email).should_not be_nil
       controller.should be_successful
     end.should_not change(Author, :count)
   end
   
   it "should have a route for author activation" do
     with_route("/authors/activate/1234") do |params|
       params[:controller].should == "Authors"
       params[:action].should == "activate" 
       params[:activation_code].should == "1234"    
     end
   end

   it 'activates author' do
     create_author(:login => "aaron", :password => "test", :password_confirmation => "test")
     @author = controller.assigns(:author)
     Author.authenticate('aaron', 'test').should be_nil
     get "/authors/activate/1234" 
     controller.should redirect_to("/")
   end

   it 'does not activate author without key' do
       get "/authors/activate"
       controller.should be_missing
   end
     
   def create_author(options = {})
     post "/authors", :author => valid_author_hash.merge(options)
   end
end