module AuthorSpecHelper
  def valid_author_hash
    { :login                  => String.random(10),
      :email                  => "#{String.random}@example.com",
      :password               => "sekret",
      :password_confirmation  => "sekret"}
  end
end