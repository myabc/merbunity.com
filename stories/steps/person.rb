steps_for(:person) do
  Given("no people in the database") do
    Person.auto_migrate!
  end
  Given("an anonymous person") do
    @person = nil
  end
  Given("an active person") do
    unless @person = Person.first(:login => "kevin")
      @person = Person.new(valid_person_hash.with(:login => "kevin"))
      @person.save
      @person.activate
    end
  end
  Given("an active publisher") do
    unless @person = Person.first(:login => "lucy")
      @person = Person.new(valid_person_hash.with(:login => "lucy"))
      @person.save
      @person.activate
      @person.make_publisher!
      @person.save
    end
  end
  Given("an active publisher named: $login") do |login|
    unless @person = Person.first_publisher(:login => login)
      @person = Person.create(valid_person_hash.with(:login => login))
      @person.activate
      @person.make_publisher!
      @person.save
    end
  end
  Given("an active person named: $name") do |login|
    if Person.first(:login => login)
      @person = Person.first(:login => login)
    else
      @person = Person.create(valid_person_hash.with(:login => login))
      @person.activate
      @person.save
    end
  end
  Then("the person should be logged in") do
    controller.should be_logged_in
  end
    
end