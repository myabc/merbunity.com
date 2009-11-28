# require File.join(File.dirname(__FILE__), '../models/screencast')
class Screencasts < Application
  publishable_resource Screencast

  before :ensure_logged_in_for_pending, :only => :download

  params_protected :screencast => [:owner, :owner_id, :published_on, :draft_status]

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

  # Put this in so that we can still get links when not behind nginx_send_file
  if Merb.env != "production"
    def send_screencast(screencast)
      send_file(screencast.full_path)
    end
  else

    # Requires a setup in nginx to work.
    # sendfile on;
    # location /protected_screencast/ {
    #   alias /path/to/app/current/;
    #   internal;
    # }
    def send_screencast(screencast)
      headers['Content-Disposition'] = "attachment; filename = #{screencast.filename}"
      headers['Content-Type'] ="#{screencast.content_type}"
      nginx_send_file("/protected_screencast" / screencast.relative_path / screencast.filename )
      redirect url(:screencast, screencast)
    end
  end

end
