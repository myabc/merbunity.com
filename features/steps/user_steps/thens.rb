Then /^I should see fields for a person form$/ do
  response.should have_xpath("//form//input[@name='user[login]'][@type='text']")
  response.should have_xpath("//form//input[@name='user[password]'][@type='password']")
  response.should have_xpath("//form//input[@name='user[password_confirmation]'][@type='password']")
  response.should have_xpath("//form//input[@type='submit']")
end
