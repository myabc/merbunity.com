require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe NewsItem do

  before(:each) do
    @klass = NewsItem
  end

  it_should_behave_like "an article"

end
