steps_for(:casts) do
  Given("cast upload form data") do
    # @_form_data = {:cast => valid_cast_hash}.to_mash
    @_form_data = valid_multipart_cast_mash
  end
  Given("no current casts in the database") do
    Cast.auto_migrate!
  end
  When("the author posts form data to: $path") do |path|
    multipart_post(path, @_form_data) do |controller|
      full_hash = controller.params.merge(@_form_data)
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
      # controller.stub!(:params).and_return(full_hash)
    end
  end
  Then("there should be $count casts in the database") do |count|
    Cast.count.should == count.to_i
  end
  Then("the author should be redirected to the new cast") do 
    cast = controller.assigns(:cast)
    controller.should redirect_to(url(:cast, cast))
  end
  
end