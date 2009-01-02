require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Tutorial do
  
  before(:each) do
    @klass = Tutorial
  end
  
  it_should_behave_like "an article"

end