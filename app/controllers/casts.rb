class Casts < Application
  # provides :xml, :js, :yaml
  before :login_required, :only => [:new, :create, :edit]
  
  def index
    @casts = Cast.all
    render @casts
  end
  
  def show(id)
    @cast = Cast.first(:id => id)
    raise NotFound unless @cast
    render @cast
  end
  
  def new
    only_provides :html
    @cast = Cast.new
    render @cast
  end
  
  def create(cast)
    @cast = Cast.new(cast)
    @cast.author = current_author
    if @cast.save
      redirect url(:cast, @cast)
    else
      render :action => :new
    end
  end
  
  def edit(id)
    only_provides :html
    @cast = Cast.first(:id => id)
      raise NotFound unless @cast
      raise NotFound if !current_author.publisher? && @cast.author != current_author
    render
  end
  
  def update(id, cast)
    @cast = Cast.first(:id => id)
    raise NotFound unless @cast
    if @cast.update_attributes(cast)
      redirect url(:cast, @cast)
    else
      raise BadRequest
    end
  end
  
  def destroy(id)
    @cast = Cast.fisrt(:id => id)
    raise NotFound unless @cast
    if @cast.destroy!
      redirect url(:casts)
    else
      raise BadRequest
    end
  end
end