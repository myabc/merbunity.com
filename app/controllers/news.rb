class News < Application
  # provides :xml, :yaml, :js
  
  def index
    @news_story = NewsStory.all
    display @news_stories
  end

  def show
    @news_story = NewsStory.first(params[:id])
    raise NotFound unless @news_story
    display @news_story
  end

  def new
    only_provides :html
    @news_story = NewsStory.new
    render
  end

  def edit
    only_provides :html
    @news_story = NewsStory.first(params[:id])
    raise NotFound unless @news_story
    render
  end

  def create
    @news_story = NewsStory.new(params[:news_story])
    if @news_story.save
      redirect url(:news_story, @news_story)
    else
      render :new
    end
  end

  def update
    @news_story = NewsStory.first(params[:id])
    raise NotFound unless @news_story
    if @news_story.update_attributes(params[:news_story])
      redirect url(:news_story, @news_story)
    else
      raise BadRequest
    end
  end

  def destroy
    @news_story = NewsStory.first(params[:id])
    raise NotFound unless @news_story
    if @news_story.destroy!
      redirect url(:news_stories)
    else
      raise BadRequest
    end
  end
  
end
