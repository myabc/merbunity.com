Then /^I should see "(.*)"$/ do |text|
  response.body.should =~ /#{text}/m
end

Then /^I should not see "(.*)"$/ do |text|
  response.body.should_not =~ /#{text}/m
end

Then /^I should see an? (\w+) message$/ do |message_type|
  response.should have_xpath("//*[@class='#{message_type}']")
end

Then /^[tT]he (.*) ?request should fail/ do |_|
  response.should_not be_successful
end

Then /^[tT]he (.*) ?request should be successful/ do |_|
  response.should be_successful
end

Then /^[tT]he response should be missing/ do
  response.should be_missing
end

Then /^I should be redirected to (.*?)$/ do |url|
  response.should redirect_to(url)
end

Then /^I should see the page (.*?)$/ do |url|
  URI.parse(response.url).path.should == url
end

Then /^I should be forbidden$/ do
  response.status.should == Merb::Controller::Forbidden.status
end

Then /^the request should be in conflict$/ do
  response.status.should == Merb::Controller::Conflict.status
end

Then /^I should see a form to create new (.*?)$/ do |plural_name|
  plural_name = plural_name.gsub(" ", "_")
  xpath = "//form[@action='#{resource(plural_name.to_sym)}'][@method='post']"
  response.should match_xpath(xpath)
end

Then /^I should see a delete form for (.*?)$/ do |url|
  xpath = "//form[@action='#{url}'][input[@name='_method'][@value='delete']]"
  response.should have_xpath(xpath)
end

Then /^I should see a form to edit (.*?) (.*?)$/ do |singular_name, slug|
  klass = get_klass(singular_name)
  article = klass.first(:slug => slug)
  xpath = "//form[@action='#{resource(article)}'][@method='post'][input[@name='_method'][@value='put']]"
  response.should match_xpath(xpath)
end

Then /^I should see a "(.*?)" field with attribute value "(.*?)"$/ do |field_name, value|
  xpath = "//form//*[@name=\"#{field_name}\"][@value=\"#{value}\"]"
  response.should match_xpath(xpath)
end

Then /^I should see a "(.*?)" field containing text "(.*?)"$/ do |field, value|
  xpath = "//form//*[@name=\"#{field}\"][contains(., \"#{value}\")]"
  response.should match_xpath(xpath)
end
