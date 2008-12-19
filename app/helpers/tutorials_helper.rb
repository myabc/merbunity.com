module Merb
  module TutorialsHelper
    
    def named_index_route
      :tutorials
    end
    
    def article_header(sense = :plural)
      sense == :plural ? "Tutorials" : "Tutorial"
    end

  end
end # Merb