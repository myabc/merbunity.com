class Pending < Application

  def index 
    @casts = Cast.all
  end
  
end