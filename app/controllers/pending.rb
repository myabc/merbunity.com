class Pending < Application

  def index 
    @casts = current_author.publisher? ? Cast.all(:published_since => nil) : current_author.pending_casts
    render @casts
  end
  
end