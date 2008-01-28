steps_for(:casts) do
  Given("no pending form data") do
    @_form_data = {}
  end
  Given("cast upload form data") do
    @_form_data = valid_multipart_cast_mash
  end
  Given("update data for cast: $field $value") do |field,value|
    @_form_data[:cast] ||= {}
    @_form_data[:cast].merge!(field.to_sym => value.to_s)
  end
  
  Given("no current casts in the database") do
    Cast.auto_migrate!
  end
  Given("$number current pending casts in the database") do |number|
    number = number.to_i
    1.upto(number) do
      c = Cast.new(valid_cast_hash)
      c.author = @author
      c.save
    end
  end   
  Given("$number current published casts in the database") do |number|
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
  Given("using the first pending cast found belonging to: $name") do |login|
    a = Author.first(:login => login)
    @cast = nil and return if a.nil?
    @cast = a.pending_casts.first
  end
  When("the author posts form data to: $path") do |path|
    multipart_post(path, @_form_data) do
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end
  When("the author puts data to the current cast") do
    multipart_put(url(:cast, @cast), @_form_data) do
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
  Then("the author should be redirected to the pending cast") do
    cast = controller.assigns(:cast)
    controller.should redirect_to(url( :pending_cast, cast))
  end
  Then("the cast should be: $state") do |state|
    cast = controller.assigns(:cast)
    cast.should self.send("be_#{state}".to_sym)
  end
  Then("the cast should not be: $state") do |state|
    cast = controller.assigns(:cast)
    cast.should_not self.send("be_#{state}".to_sym)
  end
  Then("the current cast should have the attribute $attr set to $value in the database") do |attr, value|
    c = Cast.first(@cast.id)
    c.send(attr.to_sym).should == value
  end
  Then("the current cast should not be modified") do 
    c = Cast.first(@cast.id)
    c.should == @cast
  end
  Then("the controller should show $number $state casts") do |num, state|
    casts = controller.assigns(:casts)
    num = num.to_i
    case state
    when "pending"
      casts.select{|c| c.pending? }.should have(num).items      
    when "published"
      casts.select{|c| c.published? }.should have(num).items
    else
      raise "Options can only be published or pending"
    end
  end
    
  
end