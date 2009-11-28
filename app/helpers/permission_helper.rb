module Merbunity
  module PermissionHelpers

   def when_logged_in
     yield if logged_in?
   end

   def when_not_logged_in
     yield unless logged_in?
   end

   def when_admin
     yield if logged_in? && current_person.admin?
   end

   def when_publisher
     yield if logged_in? && current_person.publisher?
   end


  end
end
