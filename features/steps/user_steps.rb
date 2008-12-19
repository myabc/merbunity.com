Given /^[tT]he following users exist:$/ do |users_table|
  User.all.destroy!
  users_table.hashes.each do |hash|
    params = {}
    hash.keys.each do |k|
      params[k.to_sym] = hash[k]
    end
    params[:password_confirmation] = params[:password] if params[:password]
    User.make(params)
  end
end

Given /^[tT]he default user exists$/ do
  User.make(:login => "fred", :password => "sekrit", :password_confirmation => "sekrit")
end