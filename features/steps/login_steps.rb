Given /^I am not authenticated$/ do
  # yay!
end

Given /^I login as (.*?) with (.*?)$/ do | login, password |
  visit url(:login)
  fill_in "login", :with => login
  fill_in "password", :with => password
  click_button "Login"
  response.status.should_not == 401
end

When /^I logout$/ do
  request(url(:logout), :method => "DELETE")
end

Then /^I should require authentication$/ do
  response.status.should == 401
end

Then /^I should see the login form/ do
  xpath = "//form[@action='#{url(:login)}'][@method='post'][input[@name='_method'][@value='put']]"
  response.should match_xpath(xpath)
end
