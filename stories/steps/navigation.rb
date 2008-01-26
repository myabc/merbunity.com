steps_for(:navigation) do
  When("the author gets edit for the current cast") do 
    get(url(:edit_cast, @cast), :yields => :controller) do 
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end  
  When("the author gets $action for the current cast") do |action|
    u_r_l = case action
    when "index"
      url(:casts)
    when "show"
      url(:cast, @cast)
    when "new"
      url(:new_cast)
    when "edit"
      url(:edit_cast, @cast)
    end
    get(u_r_l, :yields => :controller) do 
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end
  
  Then("the author should be redirected to: $path") do |path|
    controller.should redirect_to(path)
  end
  Then("the author should see the error page: $exception") do |exception|
    puts controller.params[:exception].message if controller.params[:exception]
    the_exception = "Merb::Controller::#{exception}".constantize
    controller.params[:exception].class.should == the_exception
    controller.status.should == the_exception::STATUS
  end
  Then("the author should see the page: $controller $action") do |c, a|
    controller.params[:controller].downcase.should == c.downcase
    controller.params[:action].downcase.should == a.downcase
    controller.template.should match( /#{a}\.html\./i)
  end
  Then("the author should be redirected to the current cast $action page") do |action|
    puts controller.params[:exception].message if controller.params[:exception]
    case action
    when "index"
      controller.should redirect_to(url(:casts))
    when "show"
      controller.should redirect_to(url(:cast, @cast))
    when "edit"
      controller.should redirect_to(url(:edit_cast, @cast))
    when "new"
      controller.should redirect_to(url(:new_cast, @cast))
    else
      controller.should redirect_to(url(:action => action, :controller => "casts", :id => @cast.id))
    end
  end
end