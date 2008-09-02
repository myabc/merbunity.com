module DataMapper
  module Types
    class MerbunityClass < DataMapper::Type
      primitive String

      def self.load(value, property)
        value.nil? ? nil : Extlib::Inflection.constantize(value)
      end

      def self.dump(value, property)
        case value
        when String
          value
        when nil
          nil
        when Class
          value.name
        end
      end
    end # class URI
  end # module Types
end # module DataMapper
