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
  Given("an active publisher") do
    if Author.first(:login => "lucy")
      @author = Author.first(:login => "lucy")
    else
      @author = Author.new(valid_author_hash.with(:login => "lucy"))
      @author.save
      @author.activate
      @author.make_publisher!
    end
  end
  Then("the author should be logged in") do
    controller.should be_logged_in
  end
    
end