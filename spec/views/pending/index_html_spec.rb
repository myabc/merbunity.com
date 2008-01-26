require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/pending" do
  before(:each) do
    @controller,@action = get("/pending")
    @body = @controller.body
  end

  it "should mention Pending" do
    @body.should match(/Pending/)
  end
end