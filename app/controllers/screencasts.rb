class Screencasts < Application
  # provides :xml, :yaml, :js
  
  def index
    @screencasts = Screencast.all
    display @screencasts
  end

  def show
    @screencast = Screencast.first(params[:id])
    raise NotFound unless @screencast
    display @screencast
  end

  def new
    only_provides :html
    @screencast = Screencast.new
    render
  end

  def edit
    only_provides :html
    @screencast = Screencast.first(params[:id])
    raise NotFound unless @screencast
    render
  end

  def create
    @screencast = Screencast.new(params[:screencast])
    if @screencast.save
      redirect url(:screencast, @screencast)
    else
      render :new
    end
  end

  def update
    @screencast = Screencast.first(params[:id])
    raise NotFound unless @screencast
    if @screencast.update_attributes(params[:screencast])
      redirect url(:screencast, @screencast)
    else
      raise BadRequest
    end
  end

  def destroy
    @screencast = Screencast.first(params[:id])
    raise NotFound unless @screencast
    if @screencast.destroy!
      redirect url(:screencasts)
    else
      raise BadRequest
    end
  end
  
end
