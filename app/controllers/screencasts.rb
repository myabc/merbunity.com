class Screencasts < Application

  publishable_resource Screencast
  
  # provides :xml, :yaml, :js
  before :login_required, :only => [:new, :create, :edit, :update]
  params_protected :screencast => [:owner]
  
  def index
    @screencasts = Screencast.published(:limit => 10, :order => "published_on DESC")
    display @screencasts
  end

  # Once something is published it's available for all ppl to see.
  def show(id)
    @screencast = Screencast.find_published(id)
    raise NotFound unless @screencast
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
    raise NotFound unless current_person.can_edit?(@screencast)
    render
  end

  def create(screencast)
    @screencast = Screencast.new(screencast.merge(:owner => current_person))
    if @screencast.save
      if @screencast.published?
        redirect url(:screencast, @screencast)
      else
        redirect url(:pending_screencast, @screencast)
      end
    else
      render :new
    end
  end

  def update(id, screencast = {})
    @screencast = Screencast.first(id)
    raise NotFound unless @screencast
    if @screencast.update_attributes(screencast)
      redirect url(:screencast, @screencast)
    else
      raise BadRequest
    end
  end

  def destroy(id)
    @screencast = Screencast.first(id)
    raise NotFound unless @screencast
    if @screencast.destroy!
      redirect url(:screencasts)
    else
      raise BadRequest
    end
  end
  
end
