# Commonly used webrat steps
# http://github.com/brynary/webrat

When /^I go to (.*)$/ do |path|
  visit path
end

When /^I press "(.*)"$/ do |button|
  click_button(button)
end

When /^I follow "(.*)"$/ do |link|
  click_link(link)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  fill_in(field, :with => value) 
end

When /^I select "(.*)" from "(.*)"$/ do |value, field|
  select(value, :from => field) 
end

When /^I check "(.*)"$/ do |field|
  check(field) 
end

When /^I uncheck "(.*)"$/ do |field|
  uncheck(field) 
end

When /^I choose "(.*)"$/ do |field|
  choose(field)
end

When /^I attach the file at "(.*)" to "(.*)" $/ do |path, field|
  attach_file(field, path)
end

When /^I (.*?) directly (to|from) (.*?) without params$/ do | method, _, url|
  request(url, :method => method)
end

When /^I (.*?) directly (to|from) (.*?) with params:$/ do |method, _, url, params_table|
  params = {}
  params_table.hashes.each do |hash|
    params[hash["name"]] = hash["value"]
  end
  request(url, :method => method, :params => params)
end

