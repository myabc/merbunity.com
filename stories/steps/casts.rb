steps_for(:casts) do
  Given("cast upload form data") do
    @_form_data = valid_multipart_cast_mash
  end
  Given("no current casts in the database") do
    Cast.auto_migrate!
  end
  When("the author posts form data to: $path") do |path|
    multipart_post(path, @_form_data) do
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end
  Then("there should be $count casts in the database") do |count|
    Cast.count.should == count.to_i
  end
  Then("the author should be redirected to the new cast") do 
    cast = controller.assigns(:cast)
    controller.should redirect_to(url(:cast, cast))
  end
  Then("the cast should be: $state") do |state|
    cast = controller.assigns(:cast)
    cast.should self.send("be_#{state}".to_sym)
  end
  Then("the cast should not be: $state") do |state|
    cast = controller.assigns(:cast)
    cast.should_not self.send("be_#{state}".to_sym)
  end
  
end