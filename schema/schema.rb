# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments_news_items", :id => false, :force => true do |t|
    t.integer "news_item_id"
    t.integer "comment_id"
  end

  add_index "comments_news_items", ["news_item_id"], :name => "cmnt_news_item_idx"

  create_table "comments_screencasts", :id => false, :force => true do |t|
    t.integer "screencast_id"
    t.integer "comment_id"
  end

  add_index "comments_screencasts", ["screencast_id"], :name => "cmnt_scrn_scrn_id_idx"

  create_table "comments_tutorials", :id => false, :force => true do |t|
    t.integer "tutorial_id"
    t.integer "comment_id"
  end

  add_index "comments_tutorials", ["tutorial_id"], :name => "cmnt_tut_tut_id_idx"

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.text     "description"
    t.integer  "comment_count", :default => 0
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_items", ["created_at"], :name => "news_item_created_at_idx"
  add_index "news_items", ["owner_id"], :name => "news_item_owner_idx"

  create_table "pending_comments_screencasts", :id => false, :force => true do |t|
    t.integer "screencast_id"
    t.integer "comment_id"
  end

  add_index "pending_comments_screencasts", ["screencast_id"], :name => "p_cmnt_scrn_scrn_id_idx"

  create_table "pending_comments_tutorials", :id => false, :force => true do |t|
    t.integer "tutorial_id"
    t.integer "comment_id"
  end

  add_index "pending_comments_tutorials", ["tutorial_id"], :name => "p_cmnt_tut_tut_id_idx"

  create_table "people", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "activation_code"
    t.datetime "activated_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token"
    t.datetime "publisher_since"
    t.datetime "admin_since"
    t.integer  "published_item_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["login"], :name => "person_login_idx", :unique => true

  create_table "screencasts", :force => true do |t|
    t.datetime "published_on"
    t.string   "published_status"
    t.string   "title"
    t.text     "description"
    t.text     "body"
    t.integer  "size"
    t.text     "original_filename"
    t.string   "content_type"
    t.integer  "publisher_id"
    t.integer  "owner_id"
    t.integer  "comment_count",         :default => 0
    t.integer  "pending_comment_count", :default => 0
    t.integer  "download_count",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "screencasts", ["published_on"], :name => "screencast_published_on_idx"
  add_index "screencasts", ["published_status"], :name => "screencast_published_status_idx"
  add_index "screencasts", ["owner_id"], :name => "screencast_owner_idx"

  create_table "tutorials", :force => true do |t|
    t.datetime "published_on"
    t.string   "published_status"
    t.string   "title"
    t.text     "description"
    t.text     "body"
    t.integer  "publisher_id"
    t.integer  "owner_id"
    t.integer  "comment_count",         :default => 0
    t.integer  "pending_comment_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutorials", ["published_on"], :name => "tutorial_published_on_idx"
  add_index "tutorials", ["published_status"], :name => "tutorial_published_status_idx"
  add_index "tutorials", ["owner_id"], :name => "tutorial_owner_idx"

end
