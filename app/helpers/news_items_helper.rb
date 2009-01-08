module Merb
  module NewsItemsHelper
    
    def named_index_route
      :news_items
    end
    
    def article_header(sense = :plural)
      sense == :plural ? "News Items" : "News Item"
    end

    def page_id
      "news-items"
    end

  end
end # Merb