class InitialStartMigration < ActiveRecord::Migration
            
  def self.up
    
    create_table :people do |t|
      t.string    :login
      t.string    :email
      t.string    :crypted_password
      t.string    :salt
      t.string    :activation_code
      t.datetime  :activated_at
      t.datetime  :remember_token_expires_at
      t.string    :remember_token
      t.datetime  :publisher_since
      t.datetime  :admin_since
      t.integer   :published_item_count, :default => 0

      t.timestamps
    end
    
    create_table :screencasts do |t|
      t.datetime    :published_on
      t.string      :published_status
      t.string      :title, :length => 255
      t.text        :description
      t.text        :body
      t.integer     :size
      t.text        :original_filename
      t.string      :content_type, :length => 255
      t.integer     :publisher_id
      t.integer     :owner_id
      t.integer     :comment_count, :default => 0
      t.integer     :pending_comment_count, :default => 0
      t.integer     :download_count, :default => 0
      
      t.timestamps
    end
    
    create_table :news_items do |t|
      t.string    :title, :length => 255
      t.text      :body
      t.text      :description
      t.integer   :comment_count, :default => 0
      t.integer   :owner_id
      
      t.timestamps
    end
    
    create_table :tutorials do |t|
      t.datetime    :published_on
      t.string      :published_status
      t.string      :title, :length => 255
      t.text        :description
      t.text        :body
      t.integer     :publisher_id
      t.integer     :owner_id
      t.integer     :comment_count, :default => 0
      t.integer     :pending_comment_count, :default => 0
      
      t.timestamps
    end
    
    create_table :comments do |t|
      t.text      :body
      t.integer   :owner_id
      
      t.timestamps
    end
    
    create_table :comments_tutorials, :id => false  do |t|
      t.integer :tutorial_id
      t.integer :comment_id
    end
    
    create_table :comments_screencasts, :id => false  do |t|
      t.integer :screencast_id
      t.integer :comment_id
    end
    
    create_table :pending_comments_tutorials, :id => false  do |t|
      t.integer :tutorial_id
      t.integer :comment_id
    end
    
    create_table :pending_comments_screencasts, :id => false do |t|
      t.integer :screencast_id
      t.integer :comment_id
    end
    
    create_table :comments_news_items, :id => false  do |t|
      t.integer :news_item_id
      t.integer :comment_id
    end
    
    
    say "Creating Indexes"
    add_index :people,        ["login"],            :name => "person_login_idx", :unique => true
    
    add_index :screencasts,   ["owner_id"],         :name => "screencast_owner_idx"
    add_index :screencasts,   ["published_status"], :name => "screencast_published_status_idx"
    add_index :screencasts,   ["published_on"],     :name => "screencast_published_on_idx"
    
    add_index :news_items,     ["owner_id"],         :name => "news_item_owner_idx"
    add_index :news_items,     ["created_at"],       :name => "news_item_created_at_idx"
    
    add_index :tutorials,   ["owner_id"],         :name => "tutorial_owner_idx"
    add_index :tutorials,   ["published_status"], :name => "tutorial_published_status_idx"
    add_index :tutorials,   ["published_on"],     :name => "tutorial_published_on_idx"
    
    add_index :comments_tutorials,            ["tutorial_id"],    :name => "cmnt_tut_tut_id_idx"
    add_index :pending_comments_tutorials,    ["tutorial_id"],    :name => "p_cmnt_tut_tut_id_idx"
    add_index :comments_screencasts,          ["screencast_id"],  :name => "cmnt_scrn_scrn_id_idx"
    add_index :pending_comments_screencasts,  ["screencast_id"],  :name => "p_cmnt_scrn_scrn_id_idx"
    add_index :comments_news_items,            ["news_item_id"],   :name => "cmnt_news_item_idx"  
    
  end
  
  def self.down
    remove_index :people,                       "person_login_idx"
    
    remove_index :screencasts,                  "screencast_owner_idx"
    remove_index :screencasts,                  "screencast_published_status_idx"
    remove_index :screencasts,                  "screencast_published_on_idx"
    
    remove_index :news_item,                    "news_item_owner_idx"
    remove_index :news_item,                    "news_item_created_at_idx"
    
    remove_index :tutorials,                    "tutorial_owner_idx"
    remove_index :tutorials,                    "tutorial_published_status_idx"
    remove_index :tutorials,                    "tutorial_published_on_idx"
    
    remove_index :comments_tutorials,           "cmnt_tut_tut_id_idx"
    remove_index :pending_comments_tutorials,   "p_cmnt_tut_tut_id_idx"
    remove_index :comments_screencasts,         "cmnt_scrn_scrn_id_idx"
    remove_index :pending_comments_screencasts, "p_cmnt_scrn_scrn_id_idx"
    remove_index :comments_news_items,           "cmnt_news_item_idx"  

    drop_table :people
    drop_table :screencasts
    drop_table :news_items
    drop_table :tutorials
    drop_table :comments
    drop_table :comments_tutorials
    drop_table :comments_screencasts
    drop_table :pending_comments_tutorials
    drop_table :pending_comments_screencasts
    drop_table :comments_news_items

  end
end
