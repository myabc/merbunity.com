class Casts < Application
  provides :xml, :js, :yaml
  
  def index
    @casts = Cast.all
    render @casts
  end
  
  def show(id)
    @cast = Cast[id]
    raise NotFound unless @cast
    render @cast
  end
  
  def new
    only_provides :html
    @cast = Cast.new
    render @cast
  end
  
  def create(cast)
    puts "IT IS #{cast[:uploaded_file]["tempfile"]}"
    @cast = Cast.new(cast)
    if @cast.save
      redirect url(:cast, @cast)
    else
      render :action => :new
    end
  end
  
  def edit(id)
    only_provides :html
    @cast = Cast[id]
    raise NotFound unless @cast
    render
  end
  
  def update(id, cast)
    @cast = Cast[id]
    raise NotFound unless @cast
    if @cast.update_attributes(cast)
      redirect url(:cast, @cast)
    else
      raise BadRequest
    end
  end
  
  def destroy(id)
    @cast = Cast[id]
    raise NotFound unless @cast
    if @cast.destroy!
      redirect url(:casts)
    else
      raise BadRequest
    end
  end
end