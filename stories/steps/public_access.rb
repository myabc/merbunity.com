steps_for(:public_access) do
  Given("an anonymous user") do
    @user = nil
  end
  When("the user visits $path") do |path|
    get path
  end
end