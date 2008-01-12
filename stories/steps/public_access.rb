steps_for(:public_access) do
  When("the author visits $path") do |path|
    get path and return if @author.nil?
    
    # need to stub the author into the session
    get path do |controller, request|
      controller.session[:author] = @author.id
    end
  end

end