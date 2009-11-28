module PersonSpecHelper
  def valid_person_hash
    { :login                  => String.random(10),
      :email                  => "#{String.random}@example.com",
      :password               => "sekret",
      :password_confirmation  => "sekret"}
  end
end
