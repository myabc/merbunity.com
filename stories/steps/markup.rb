steps_for(:markup) do
  Then("the visitor should see the page: $controller $action") do |c, a|
    controller.params[:controller].downcase.should == c.downcase
    controller.params[:action].downcase.should == a.downcase
    controller.template.should match( /#{a}\.html\./)
  end  
  Then("the page should have the heading: $heading") do |heading|
    element("h1").inner_text.strip.should == heading
  end  
end