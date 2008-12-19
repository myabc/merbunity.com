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
  response.should have_xpath("//ul[@class='articles']/li")
end

Then /^I should see an empty articles list$/ do
  response.should have_xpath("//div[@class='articles']")
end

Then /^I should see an article$/ do
  response.should have_xpath("//div[@class='article']")
end