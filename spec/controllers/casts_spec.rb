require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Casts Controller", "index action" do
  before(:each) do
    @controller = Casts.build(fake_request)
    @controller.dispatch('index')
  end
end