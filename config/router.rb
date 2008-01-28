# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

puts "Compiling routes.."
Merb::Router.prepare do |r|
  # RESTful routes
  # r.resources :posts
  # r.match("/").to(:controller => "Home", :action => "show").name(:welcome)
  r.match("/").to(:controller => "casts").name(:welcome)
  
  r.resources :authors
  r.match("/login").to(:controller => "Sessions", :action => "create").name(:login)
  r.match("/logout").to(:controller => "Sessions", :action => "destroy").name(:logout)
  r.match("/authors/activate/:activation_code").to(:controller => "Authors", :action => "activate").name(:author_activation)

  r.resources :casts
  
  r.to(:controller => "pending") do |p|
    p.match("/pending", :method => "get").to(:action => "index").name(:pending_casts)
    p.match("/pending/:id", :method => "get").to(:action => "show").name(:pending_cast)
    p.match("/pending/publish/:id", :method => "put").to(:action => "update").name(:publish)
  end
  
  r.match("/downloads/:id").to(:controller => "casts", :action => "download").name(:download)
  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  # r.default_routes
  
  # Change this for your home page to be available at /
  # r.match('/').to(:controller => 'whatever', :action =>'index')
end
