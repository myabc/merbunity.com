Then /^I should see form fields for an? (.*?) article$/ do |singular_name|
  singular_name3 = singular_name.gsub(" ", "_")
  response.should have_xpath("//form//input[@name='#{singular_name}[title]']")
  response.should have_xpath("//form//textarea[@name='#{singular_name}[description]']")
  response.should have_xpath("//form//textarea[@name='#{singular_name}[body]']")
  response.should have_xpath("//form//input[@type='submit']")
end

Then /^the (.*?) with slug "(.*?)" should not exist$/ do |klass, slug|
  klass = Object.full_const_get(klass)
  klass.first(:slug => slug).should be_nil
end

Then /^I should see a list of articles$/ do
  response.should have_selector("ul#article-listing li")
end

Then /^there should be no articles$/ do
  response.should have_xpath("//*[@class='empty']")
end

Then /^I should see an article$/ do
  response.should have_xpath("//div[@class='article']")
end

Then /^I should see that the (.*?) is a draft$/ do |klass|
  response.should have_selector(".draft")
end

Then /^I should not see that the (.*?) is a draft$/ do |klass|
  response.should_not have_selector(".draft")
end

Then /^the (.*?) title should (not )?be "(.*?)"$/ do |klass, sense, value|
  meth = sense.nil? ? :should : :should_not
  response.send(meth, have_xpath("//*[@id='page-title'][contains(.,'#{value}')]"))
end

Then /^the (.*?) should (not )?have a (.*?) "(.*?)"$/ do |klass, sense, field, value|
  meth = sense.nil? ? :should : :should_not
  response.send(meth, have_xpath("//*[@class='#{field}'][contains(., '#{value}')]"))
end
