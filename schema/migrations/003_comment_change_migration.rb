class CommentChangeMigration < ActiveRecord::Migration
  
  def self.up
    add_column :comments, :commentable_class, :string
    add_column :comments, :status,            :string 
    
    DataMapper::Transaction.new do
      # Set the screencasts 
      adapter = repository.adapter
      scs = adapter.query("SELECT * FROM comments_screencasts")
      scs.each do |sc|
        c = Comment.get(sc.comment_id)
        c.status = "published"
        c.commentable_class = Screencast
        raise "Screencast Published" unless c.save
      end
      
      pending_sc_commentables = adapter.query("SELECT * FROM pending_comments_screencasts")
      pending_sc_commentables.each do |commentable|
        c = Comment.get(commentable.comment_id)
        s = Screencast.get(commentable.screencast_id)
        c.status = "pending"
        c.commentable_class = Screencast
        raise "Pending Screencast" unless c.save
        cs = CommentableScreencasts.new
        cs.screencast = s
        cs.comment = c
        raise "Pending Screencast Comment Join" unless cs.save
      end
      
      # Do the Tutorials
      tcs = adapter.query("SELECT * FROM comments_tutorials")
      tcs.each do |ts|
        c = Comment.get(ts.comment_id)
        c.status = "published"
        c.commentable_class = Tutorial
        raise "Tutorial Published" unless c.save
      end
      
      ptcs = adapter.query("SELECT * FROM pending_comments_tutorials")
      ptcs.each do |ts|
        c = Comment.get(ts.comment_id)
        t = Tutorial.get(ts.tutorial_id)
        c.status = "pending"
        c.commentable_class = Tutorial
        raise "Tutorial Pending" unless c.save
        ct = CommentableTutorial.new
        ct.tutorial = t
        ct.comment = c
        raise "Pending Tutorial Comment Join" unless ct.save
      end
      
      # Do the news items
      nics = adapter.query("SELECT * FROM comments_news_items")
      nics.each do |nic|
        c = Comment.get(nic.comment_id)
        c.status = "published"
        c.commentable_class = NewsItem
        raise "Commentable News Item" unless c.save
      end
      
    end
    drop_table :pending_comments_screencasts
    drop_table :pending_comments_tutorials
    
  end
  
  def self.down
    raise "Can't go backwards wihtout models... don't do it man"
    
  end
  
end