class NewsItem < Article
  is_draftable :title, :description, :slug, :body
end
