steps_for(:casts) do
  Given("cast upload form data") do
    @_form_data = valid_multipart_cast_mash
  end
  Given("no current casts in the database") do
    Cast.auto_migrate!
  end
  Given("$number current pending casts in the database") do |number|
    Cast.auto_migrate!
    number = number.to_i
    1.upto(number) do
      c = Cast.new(valid_cast_hash)
      c.author = @author
      c.save
    end
  end   
  Given("$number current published casts in the database") do |number|
    Cast.auto_migrate!
    number = number.to_i
    1.upto(number) do
      c = Cast.new(valid_cast_hash)
      c.author = @author
      c.save
      c.publish!
    end
  end
  Given("using the first cast found") do
    @cast = Cast.first
  end  
  Given("using the first cast found belonging to: $name") do |login|
    a = Author.first(:login => login)
    @cast = nil and return if a.nil?
    @cast = a.casts.first
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