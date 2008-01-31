class Pending < Application
  before :login_required

  def index 
    @casts = current_person.publisher? ? Cast.all(:published_since => nil) : current_person.pending_casts
    render @casts
  end
  
  def show(id)
    id = id.to_i
    @cast = if current_person.publisher?
      Cast.first(:id => id, :published_since => nil)
    else
      current_person.pending_casts.select{|c| c.id == id}.first
    end
    raise NotFound if @cast.nil?
    render @cast
  end
  
  # Used only to publish a cast.  There are no 
  # other updates available from this update action
  # TODO: Add a mailer into publising to alert the owner that it has been published
  #       Do that in here so that email is not sent when a publisher creates a cast.
  def update(id)
    raise Unauthorized unless current_person.publisher?
    id = id.to_i
    @cast = Cast.first(:id => id, :published_since => nil)
    raise NotFound if @cast.nil?
    @cast.publish!
    redirect url(:cast, @cast)
  end
  
end