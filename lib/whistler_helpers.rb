class DataMapper::Base
  
  class << self
    def whistler_properties(*props)
      @_whistler_properties = props.flatten.uniq
      
      before_save :whistle      
    end
    
    def get_whistler_properties
      @_whistler_properties
    end
  end
  
  private
  
  def whistle
    return unless self.dirty?
    self.class.get_whistler_properties.each do |prop|
      ivar = instance_variable_get("@#{prop}")
      ivar = Whistler.white_list(ivar) unless ivar.nil? || !dirty_attributes.include?(prop)
    end
  end
  
end