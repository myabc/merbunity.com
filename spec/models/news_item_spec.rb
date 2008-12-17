require File.join( File.dirname(__FILE__), '..', "spec_helper" )
require File.expand_path(File.join(File.dirname(__FILE__), 'shared_article_spec' ))

describe NewsItem do
  
  before(:each) do
    @klass = NewsItem
  end
  
  it_should_behave_like "an article"

end