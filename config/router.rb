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

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # RESTful routes
  # r.resources :posts
  # 
  r.match("/").to(:controller => "welcome", :action => "index", :format => "html")
  
  [:screencasts, :tutorials].each do |res|
    r.resources res, :collection => {:pending => :get, :my_pending => :get, :drafts => :get}, 
                              :member     => {:publish => :put}
  end
  r.match("/screencasts/:id/download", :method => :get).to(:controller => "screencasts", :action => "download").name(:download_screencast) 
      
  r.resources :news
  r.resources :feedback
  r.resources :passwords
  r.match("/passwords", :method => "put").to(:controller => "passwords", :action => "update")
  
  ###########################################################################################################
  #                                                                                                         #
  #                           COMMENT ROUTES                                                                #
  #                                                                                                         #
  ###########################################################################################################
  r.match("/:klass/:id/comments", :method => :post).to(:controller => "Comments", :action => "create").name(:add_comment)
  
  r.to(:controller => "PendingFeatures") do |f|
    f.match("/blogs").to(:action => "blogs" ).name(:blogs)
    f.match("/sites").to(:action => "sites").name(:sites)
    f.match("/projects").to(:action => "projects").name(:projects)
    f.match("/terms_of_service").to(:action => "terms_of_service").name(:tos)
    f.match("/faq").to(:action => "faq").name(:faq)
  end

  # r.resources :screencasts, :collection => {:pending => :get}
  
  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  # r.default_routes
  
  # Change this for your home page to be available at /
  # r.match('/').to(:controller => 'whatever', :action =>'index')
end

AuthenticatedSystem.add_routes rescue nil
