require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Screencasts, "index action" do
  before(:each) do
    dispatch_to(Screencasts, :index)
  end
end