require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/people" do
  before(:each) do
    @response = request("/people")
  end
end
