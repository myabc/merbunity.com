describe "A model that implements Merbunity::Permissions::User", :shared => true do
  
  it "should include Merbunity::Permissions::User" do
    @klass.should_not be_nil
    @klass.should include(Merbunity::Permissions::User)
  end
  
end

describe "a model that implements Merbunity::Permissons::ProtectedModel", :shared => true do
  
  it "should implement all the methods of Merbunity::Permissions::ProtectedModel" do 
    @klass.should_not be_nil
    obj = @klass.new
    Merbunity::Permissions::ProtectedModel.public_instance_methods.each do |m|
      obj.should respond_to(m.to_sym)
    end
  end
  
end