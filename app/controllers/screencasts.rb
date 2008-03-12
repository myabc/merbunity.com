class Screencasts < Application

  publishable_resource Screencast
  
  provides :js
  before :login_required, :only => [:new, :create, :edit, :update, :destroy]
  
  params_protected :screencast => [:owner]
  
  def index
    @screencasts = Screencast.published(:limit => 10)
    display @screencasts
  end

  # TODO make this so that it checks for pending status.  Adjust the normal permissions
  # to account for if it's pending and if your a publisher  or owner etc.
  def show(id)
    @screencast = Screencast.find_published(id)
    raise NotFound unless @screencast
    raise Unauthorized unless @screencast.viewable_by?(current_person)
    display @screencast
  end

  def new(screencast = {})
    only_provides :html
    @screencast = Screencast.new(screencast)
    render
  end
  
  def edit(id)
    only_provides :html
    @screencast = Screencast.first(id)
    raise NotFound unless @screencast
    raise Unauthorized unless current_person.can_edit?(@screencast)
    render
  end

  def create(screencast)
    @screencast = Screencast.new(screencast.merge(:owner => current_person))
    if @screencast.save
      redirect url(:screencast, @screencast)
    else
      render :new
    end
  end

  def update(id, screencast = {})
    @screencast = Screencast.first(id)
    raise NotFound unless @screencast
    raise Unauthorized unless @screencast.editable_by?(current_person)
    if @screencast.update_attributes(screencast)
      redirect url(:screencast, @screencast)
    else
      render :edit
    end
  end

  def destroy(id)
    @screencast = Screencast.first(id)
    raise NotFound unless @screencast
    raise Unauthorized unless current_person.can_destroy?(@screencast)
    if @screencast.destroy!
      redirect url(:screencasts)
    else
      raise BadRequest
    end
  end
  
end
