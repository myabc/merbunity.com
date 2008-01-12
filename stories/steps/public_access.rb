steps_for(:public_access) do
  Given("an anonymous author") do
    @author = nil
  end
  When("the author visits $path") do |path|
    get path and return if @author.nil?
    
    # need to stub the author into the session
    get path do |controller, request|
      controller.session[:author] = @author.id
    end
  end
  Then("the author should be redirected to: $path") do |path|
    controller.should redirect_to(path)
  end
end