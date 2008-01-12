module AuthenticatedSystem
  module OrmMap
    
    def find_authenticated_model_with_id(id)
      Author.first(:id => id)
    end
    
    def find_authenticated_model_with_remember_token(rt)
      Author.first(:remember_token => rt)
    end
    
    def find_activated_authenticated_model_with_login(login)
      if Author.instance_methods.include?("activated_at")
        Author.first(:login => login, :activated_at.not => nil)
      else
        Author.first(:login => login)
      end
    end
    
    def find_activated_authenticated_model(activation_code)
      Author.first(:activation_code => activation_code)
    end  
    
    def find_with_conditions(conditions)
      Author.first(conditions)
    end
    
    # A method to assist with specs
    def clear_database_table
      Author.auto_migrate!
    end
  end
  
end