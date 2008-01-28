steps_for(:public_access) do
  When("the author visits $path") do |path|
    get(path, :yields => :controller) and return if @author.nil?
    # need to stub the author into the session
    get(path, :yields => :controller) do |controller|
      controller.session[:author] = @author.id
    end
  end

end