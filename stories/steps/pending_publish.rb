steps_for(:pending_publish) do
  When("the publisher publishes the cast") do
    put(url(:publish, @cast), :yields => :controller) do
      controller.stub!(:current_author).and_return(@author) unless @author.nil?
    end
  end  
end