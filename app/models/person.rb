class Person
  include DataMapper::Resource
  include Merbunity::Permissions::User
  include MerbAuth::Adapter::DataMapper
  
  attr_accessor :password, :password_confirmation
  
  property :id,                         Integer, :serial => true
  property :login,                      String,  :nullable => false, :length => 3..40, :unique => true
  property :email,                      String,  :nullable => false, :length => 3..100 
  property :crypted_password,           String
  property :salt,                       String
  property :activation_code,            String
  property :activated_at,               DateTime
  property :remember_token_expires_at,  DateTime
  property :remember_token,             String
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  property :publisher_since,            DateTime
  property :admin_since,                DateTime
  property :published_item_count,       Integer,   :default => 0
  property :password_reset_key,         String, :writer => :protected
    
  validates_format            :email,                   :as => :email_address
  validates_is_unique         :email
  validates_present           :password,                :if => proc {|m| m.password_required?}
  validates_present           :password_confirmation,   :if => proc {|m| m.password_required?}
  validates_length            :password,                :within => 4..40, :if => proc { |m| m.password_required?}
  validates_is_confirmed      :password,                :if => proc{|m| !m.password.nil?}
    
  before :save,   :encrypt_password
  before :create, :make_activation_code
  after  :create, :send_signup_notification
  
  has n, :news_items,   :child_key => [:owner_id]
  has n, :screencasts,  :child_key => [:owner_id]
  has n, :tutorials,    :child_key => [:owner_id]
  
  def attribute_to
    self.login
  end
  
  def self.first_publisher(opts)
    self.first(opts.merge(:publisher_since.not => nil))
  end
  
  def publisher?
    !self.publisher_since.nil?
  end
  
  def make_publisher!
    self.publisher_since ||= DateTime.now
    save
  end
  
  def publish(obj)
    return false unless self.can_publish?(obj)
    obj.publish!(self)
  end
  
  def admin?
    !self.admin_since.nil?
  end
  
  def make_admin!
    self.admin_since ||= DateTime.now
    save
  end
  
end