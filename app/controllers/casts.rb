class Casts < Application
  before :login_required, :only => [:new, :create, :edit, :update]
  
  def index
    puts "IN INDEX"
    @casts = Cast.all(:published_since.not => nil, :limit => 10, :order => "published_since DESC")
    puts "FOUND CASTS"
    render @casts
  end
  
  def show(id)
    @cast = Cast.first(:id => id, :published_since.not => nil)
    return redirect( url(:casts) ) if @cast.nil?
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
      if @cast.published?
        redirect url(:cast, @cast)
      else
        redirect url(:pending_cast, @cast)
      end
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
    raise NotFound if @cast.nil? || !current_author.can_edit?(@cast)
    if @cast.update_attributes(cast)
      redirect url(:cast, @cast)
    else
      raise BadRequest
    end
  end
  
  def destroy(id)
    @cast = Cast.fisrt(:id => id)
    raise NotFound if @cast.nil? || !current_author.can_destroy?(@cast)
    if @cast.destroy!
      redirect url(:casts)
    else
      raise BadRequest
    end
  end
  
  def download(id)
    @cast = Cast.first(:id => id)
    raise NotFound if @cast.nil?
    nginx_send_file(@cast.full_path)
    "Done"
  end
    
    
    
end