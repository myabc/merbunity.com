module AuthenticatedSystem
  module OrmMap
    
    def find_authenticated_model_with_id(id)
      Person.first(:id => id)
    end
    
    def find_authenticated_model_with_remember_token(rt)
      Person.first(:remember_token => rt)
    end
    
    def find_activated_authenticated_model_with_login(login)
      if Person.instance_methods.include?("activated_at")
        Person.first(:login => login, :activated_at.not => nil)
      else
        Person.first(:login => login)
      end
    end
    
    def find_activated_authenticated_model(activation_code)
      Person.first(:activation_code => activation_code)
    end  
    
    def find_with_conditions(conditions)
      Person.first(conditions)
    end
    
    # A method to assist with specs
    def clear_database_table
      Person.auto_migrate!
    end
  end
  
end