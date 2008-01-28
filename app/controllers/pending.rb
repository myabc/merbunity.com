class Pending < Application
  before :login_required

  def index 
    @casts = current_author.publisher? ? Cast.all(:published_since => nil) : current_author.pending_casts
    render @casts
  end
  
  def show(id)
    id = id.to_i
    @cast = if current_author.publisher?
      Cast.first(:id => id, :published_since => nil)
    else
      current_author.pending_casts.select{|c| c.id == id}.first
    end
    raise NotFound if @cast.nil?
    render @cast
  end
  
  def update(id)
    id = id.to_i
    raise Unauthorized unless current_author.publisher?
    @cast = Cast.first(:id => id, :published_since => nil)
    raise NotFound if @cast.nil?
    @cast.publish!
    redirect url(:cast, @cast)
  end
  
end