require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Feedback, "index action" do
  before(:each) do
    dispatch_to(Feedback, :index)
  end
end
