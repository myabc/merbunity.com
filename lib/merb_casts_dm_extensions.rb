module MerbCasts
  module DataMapperExtensions
  
  module ClassMethods
      #Gets the max value for the field
      def max(attr)
        database.query("SELECT max(#{attr}) FROM #{database.table(self)};").first
      end
    end
  end
end


Merb::BootLoader.after_app_loads do 
  DataMapper::Base.send(:extend, MerbCasts::DataMapperExtensions::ClassMethods)
end