require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe "/casts/new" do
  before(:each) do
    @controller,@action = get("/casts/new")
    @body = @controller.body
  end

  it "should mention Casts" do
    @body.should match(/Casts/)
  end
end