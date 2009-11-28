require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Comments, "Create action" do

  before(:all) do
    Screencast.auto_migrate!
    Person.auto_migrate!

    @person = Person.create(valid_person_hash)
    @person.activate
    @person.save

    @publisher = Person.create(valid_person_hash)
    @publisher.activate
    @publisher.make_publisher!
  end

  before(:each) do
    Merb::Mailer.deliveries.clear

    CommentableNewsItems.auto_migrate!
    CommentableScreencasts.auto_migrate!
    CommentableTutorials.auto_migrate!
    Comment.auto_migrate!

    @pending_screencast = Screencast.new(valid_screencast_hash.with(:owner => @person ))
    @pending_screencast.save
    @person.publish(@pending_screencast)

    @published_screencast = Screencast.new(valid_screencast_hash.with(:owner => @publisher ))
    @published_screencast.save
    @publisher.publish(@published_screencast)

  end

  it "should setup the spec correctly" do
    @publisher.should be_publisher
    @person.should_not be_publisher

    Person.first(:id => @person.id).should_not be_publisher
    Person.first(:id => @publisher.id).should be_publisher

    @pending_screencast.should be_pending
    @published_screencast.should be_published
  end

  it "should create a pending comment on the pending screencast" do
    count = @pending_screencast.pending_comments.size
    controller = dispatch_to(Comments, :create, :comment => valid_comment_hash.except(:owner),
                                                :klass => "Screencast",
                                                :id => @pending_screencast.id ) do |c|
      c.stub!(:current_person).and_return(@person)
      c.stub!(:logged_in?).and_return(true)
    end
    @pending_screencast.reload
    @pending_screencast = Screencast.get(@pending_screencast.id)
    @pending_screencast.comments.should be_empty
    @pending_screencast.pending_comments.size.should == count.next
    controller.flash[:notice].should_not be_blank
  end

  it "should create a published comment on a published screencast" do
    count = @published_screencast.comments.size
    controller = dispatch_to(Comments, :create, :comment => valid_comment_hash.except(:owner),
                                                :klass => "Screencast",
                                                :id => @published_screencast.id ) do |c|
      c.stub!(:current_person).and_return(@person)
      c.stub!(:logged_in?).and_return(true)
    end
    @published_screencast = Screencast.get(@published_screencast.id)
    @published_screencast.comments.size.should == count.next
    @published_screencast.pending_comments.should be_empty
    controller.flash[:notice].should_not be_blank
  end

  it "should set the owner of the comment to the current_person" do
    p = Person.new(valid_person_hash)
    p.save
    controller = dispatch_to(Comments,:create,  :comment => valid_comment_hash.except(:owner),
                                                :klass => "Screencast",
                                                :id => @published_screencast.id) do |c|
      c.stub!(:current_person).and_return(p)
      c.stub!(:logged_in?).and_return(true)
    end
    controller.assigns(:comment).owner.should == p
  end

  it "should redirect to the referrer if the comment doesn't save" do
    c = mock("comment", :null_object => true)
    c.stub!(:save).and_return false
    c.stub!(:id).and_return(123445)
    Comment.should_receive(:new).and_return(c)
    controller = dispatch_to(Comments, :create, :comment => valid_comment_hash.except(:owner),
                                                :klass => "Screencast",
                                                :id => @published_screencast.id) do |ctr|
      ctr.stub!(:current_person).and_return(@person)
      ctr.stub!(:logged_in?).and_return(true)
      ctr.request.stub!(:referer).and_return("REFERRER")
    end
    controller.should redirect_to("REFERRER")
  end

  it "should send a notice to the objects owner to alert them of the ticket" do
    c = dispatch_to(Comments, :create, :comment => valid_comment_hash.except(:owner),
                              :klass => "Screencast",
                              :id => @published_screencast.id) do |c|
      c.stub!(:current_person).and_return(@person)
      c.stub!(:logged_in?).and_return(true)
    end
    email = Merb::Mailer.deliveries.last
    email.should_not be_nil
    email.assigns(:headers).should include("to: #{@published_screencast.owner.email}")
    email.text.should match(%r!#{@person.login}!)
    email.text.should match(%r!#{c.absolute_url(:screencast, @published_screencast)}!)
  end

end
