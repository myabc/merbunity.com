steps_for(:pending_publish) do
  When("the publisher publishes the cast") do
    put(url(:publish, @cast), :yields => :controller) do
      controller.stub!(:current_person).and_return(@person) unless @person.nil?
    end
  end  
end