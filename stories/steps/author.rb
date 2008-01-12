steps_for(:author) do
  Given("an active author") do
    if Author.first(:login => "kevin")
      @author = Author.first(:login => "kevin")
    else
      @author = Author.new(valid_author_hash.with(:login => "kevin"))
      @author.save
      @author.activate
    end
  end
  Then("the author should be logged in") do
    controller.send(:current_author).should eql(@author)
  end
    
end