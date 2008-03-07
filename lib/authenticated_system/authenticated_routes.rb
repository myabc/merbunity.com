# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "Sessions", :action => "create").name(:login)
        r.match("/logout").to(:controller => "Sessions", :action => "destroy").name(:logout)
        r.match("/people/activate/:activation_code").to(:controller => "People", :action => "activate").name(:person_activation)
        r.resources :people
        r.resources :sessions
      end
    end
  end
end