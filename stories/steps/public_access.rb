steps_for(:public_access) do
  When("the person visits $path") do |path|
    get(path, :yields => :controller) and return if @person.nil?
    # need to stub the person into the session
    get(path, :yields => :controller) do |controller|
      controller.session[:person] = @person.id
    end
  end

end