steps_for(:author) do
  Given("an anonymous author") do
    @author = nil
  end
  Given("an active author") do
    unless @author = Author.first(:login => "kevin")
      @author = Author.new(valid_author_hash.with(:login => "kevin"))
      @author.save
      @author.activate
    end
  end
  Given("an active publisher") do
    unless @author = Author.first(:login => "lucy")
      @author = Author.new(valid_author_hash.with(:login => "lucy"))
      @author.save
      @author.activate
      @author.make_publisher!
      @author.save
    end
  end
  Given("an active publisher named: $login") do |login|
    unless @author = Author.first_publisher(:login => login)
      @author = Author.create(valid_author_hash.with(:login => login))
      @author.activate
      @author.make_publisher!
      @author.save
    end
  end
  Given("an active author named: $name") do |login|
    if Author.first(:login => login)
      @author = Author.first(:login => login)
    else
      @author = Author.create(valid_author_hash.with(:login => login))
      @author.activate
    end
  end
  Then("the author should be logged in") do
    controller.should be_logged_in
  end
    
end