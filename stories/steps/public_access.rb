steps_for(:public_access) do
  Given("an anonymous user") do
    @user = nil
  end
  When("user visits $path") do |path|
    get path
  end
end