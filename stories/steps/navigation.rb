steps_for(:navigation) do
  When("the author gets edit for the current cast") do 
    get url(:edit_cast, @cast) do 
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end  
  Then("the author should be redirected to: $path") do |path|
    controller.should redirect_to(path)
  end
  Then("the author should see the error page: $exception") do |exception|
    the_exception = "Merb::Controller::#{exception}".constantize
    controller.params[:exception].class.should == the_exception
    controller.status.should == the_exception::STATUS
  end
  Then("the author should see the page: $controller $action") do |c, a|
    controller.params[:controller].downcase.should == c.downcase
    controller.params[:action].downcase.should == a.downcase
    controller.template.should match( /#{a}\.html\./i)
  end
end