describe "a login form", :shared => true do
  it "should have a form that points to the login action" do
    xpath = "//form[@action='#{url(:login)}'][@method='post'][input[@name='_method'][@value='put']]"
    @response.should match_xpath(xpath)
  end
end