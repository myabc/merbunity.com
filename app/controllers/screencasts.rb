class Screencasts < Application

  before :non_publisher_help

  publishable_resource Screencast

  before :login_required, :only => [:new, :create, :edit, :update, :destroy]
  
  before :ensure_logged_in_for_pending, :only => :download
  before :find_screencast, :only => [:destroy, :show, :edit, :update]
  
  params_protected :screencast => [:owner, :published_on, :draft_status]
  
  only_provides :html, :only => [:new, :edit]
  
  def index(page = 0)
    provides :atom
    @pager = Paginator.new(Screencast.published_count, 10) do |offset, per_page|
                  Screencast.published(:limit => per_page, :offset => offset)
             end
    @page = @pager.page(page)
    @screencasts = @page.items    
    display @screencasts
  end

  def show(id)
    raise Unauthorized unless @screencast.viewable_by?(current_person)
    display @screencast
  end

  def new(screencast = {})
    @screencast = Screencast.new(screencast)
    render
  end
  
  def edit(id)
    raise Unauthorized unless current_person.can_edit?(@screencast)
    render
  end

  def create(screencast)
    @screencast = Screencast.new(screencast.merge(:owner => current_person))
    if @screencast.save
      flash[:notice] = "Saved your screencast"
      redirect url(:screencast, @screencast)
    else
      flash[:error] = "Something went wrong"
      render :new
    end
  end

  def update(id, screencast = {})
    raise Unauthorized unless current_person.can_edit?(@screencast)
    @screencast.published_status = Screencast.status_values[:draft_status] if params[:save_as_draft] == "1"
    if @screencast.update_attributes(screencast)
      flash[:notice] = "Updated your screencast"
      redirect url(:screencast, @screencast)
    else
      flash[:error] = "There was an error editing your Screencast"
      render :edit
    end
  end

  def destroy(id)
    raise Unauthorized unless current_person.can_destroy?(@screencast)
    if @screencast.destroy!
      flash[:notice] = "Screencast Deleted"
      redirect url(:screencasts)
    else
      flash[:error] = "Could not delete your Screencast"
      raise BadRequest
    end
  end
  
  # only let a person who can view this download it
  def download(id)
    
    raise NotFound if @screencast.nil?
    raise Unauthorized unless @screencast.viewable_by?(current_person)
    
    # increment the downlaad count if it's published
    if @screencast.published?
      @screencast.download_count = @screencast.download_count + 1
      @screencast.save
    end
    
    send_screencast(@screencast)
  end
  
  private
  
  def find_screencast
    @screencast = Screencast.first(params[:id])
    raise NotFound if @screencast.nil?
    @screencast
  end
  
  # Put this in so that we can still get links when not behind nginx_send_file
  if Merb.env != "production"
    def send_screencast(screencast)
      send_file(screencast.full_path)
    end
  else
    def send_screencast(screencast)
      nginx_send_file(screencast.full_path)
      redirect url(:screencast, screencast)
    end
  end
  
  def non_publisher_help
    return true if !logged_in? || current_person.publisher?
    throw_content :for_help, partial("shared/publishable/non_publisher_tip", :format => :html)
  end
  
  def ensure_logged_in_for_pending
    @screencast = Screencast.first(:id => params[:id])
    throw(:halt, :access_denied) if(@screencast.nil? || !@screencast.viewable_by?(current_person))
  end
  
end
