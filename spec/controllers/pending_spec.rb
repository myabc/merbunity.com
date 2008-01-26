require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Pendings Controller", "index action" do
  before(:each) do
    @controller = Pendings.build(fake_request)
    @controller.dispatch('index')
  end
end