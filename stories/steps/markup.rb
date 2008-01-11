steps_for(:markup) do
  Then("the visitor should see the page: $controller $action") do |c, a|
    controller.params[:controller].downcase.should == c.downcase
    controller.params[:action].downcase.should == a.downcase
    controller.template.should match( /#{a}\.html\./i)
  end  
  Then("the page should have the heading: $heading") do |heading|
    element("h1").inner_text.strip.should == heading
  end  
  Then("the page should match the selector: $selector") do |selector|
    controller.body.should match_selector(selector)
  end
  Then("the page should match the selector once: $selector") do |selector|
    elements(selector).should have(1).item
  end
  Then("the page should have an input named: $input_name") do |input_name|
    controller.body.should match_tag(:input, :name => input_name)
  end
end