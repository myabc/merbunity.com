class MerbAuth::Users < MerbAuth::Application
  params_protected :person => [:publisher_since, :admin_since]

  def index
    throw_content(:for_header, "People")
    render "<div class='item'>Keep an eye out.  We're jazzing up the people information so this really feels like a community</div>"
  end
end
