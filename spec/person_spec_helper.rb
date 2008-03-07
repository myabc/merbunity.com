module PersonSpecHelper
  def valid_person_hash
    { :login                  => "daniel",
      :email                  => "daniel@example.com",
      :password               => "sekret",
      :password_confirmation  => "sekret"}
  end
end