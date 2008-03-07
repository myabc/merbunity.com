module Merbunity
  module DataMapper
    module Extensions
    
      def max(attr)
        database.adapter.connection do |db|
          sql = "SELECT MAX(#{attr}) AS max FROM #{database.table(self).to_sql}"
          command = db.create_command(sql)
          command.execute_reader do |reader|
            if reader.has_rows?
              database.adapter.type_cast_value(self.table[attr].type, reader.current_row.first)
            else
              nil
            end
          end
        end
      end
    
    end
  end
end

Merb::BootLoader.after_app_loads do
  DataMapper::Base.send(:extend, Merbunity::DataMapper::Extensions)
end