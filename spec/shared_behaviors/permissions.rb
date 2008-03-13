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

describe "a controller that implements the publishable mixin", :shared => true do

  before(:all) do
    @c_ivar = @klass.name.snake_case.downcase
  end
  
  it "should be setup correctly" do
    @klass.should_not be_nil
    @klass.new(fake_request).should be_a_kind_of(Merb::Controller)
    @klass.should include(Merbunity::PublishableController::Setup)
  end
  
  it "should have a pending route for collections" do
    request_to("/#{@c_ivar}/pending").should route_to(@klass, :pending)
  end
  
  it "should have a my_pending route for collections" do
    request_to("/#{@c_ivar}/my_pending").should route_to(@klass, :my_pending)
  end
  
  it "should have a publish route for memebers" do
    request_to("/#{@c_ivar}/123/publish", :put).should route_to(@klass, :publish).with(:id => 123)
  end
  
end