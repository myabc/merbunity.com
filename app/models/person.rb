require 'digest/sha1'
begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue 
  nil
end
unless defined?(Person)
class Person
  include DataMapper::Resource
  include AuthenticatedSystem::Model
  include Merbunity::Permissions::User
  
  attr_accessor :password, :password_confirmation
  
  property :id,                         Integer, :serial => true
  property :login,                      String,  :nullable => false, :length => 3..40
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
  
  validates_is_unique         :login
  validates_format            :email,                   :as => :email_address
  validates_is_unique         :email
  validates_present           :password,                :if => proc {|m| m.password_required?}
  validates_present           :password_confirmation,   :if => proc {|m| m.password_required?}
  validates_length            :password,                :within => 4..40, :if => proc { |m| m.password_required?}
  validates_is_confirmed      :password,                :if => proc{|m| !m.password.nil?}
    
  before :save,   :encrypt_password
  before :create, :ensure_defaults # Should not be required :(
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
  
  
  # This method should not be needed.  DM was not behaving correctly
  def ensure_defaults
    self.published_item_count ||= 0
  end
  
  private :ensure_defaults
  
  ##############  Generated Code ######################
  
  def login=(value)
    attribute_set(:login, value.downcase) unless value.nil?
  end
  
  # Activates the person in the database
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save
    
    # send mail for activation
    send_activation_notification
  end
  
  ################ FORGOTTEN PASSWORD STUFF ########################
  property :password_reset_key, String, :writer => :protected
  validates_is_unique :password_reset_key, :if => Proc.new{|m| !m.password_reset_key.nil?}
  
  def forgot_password! # Must be a unique password key before it goes in the database
    pwreset_key_success = false
    until pwreset_key_success
      self.password_reset_key = self.class.make_key
      self.save
      pwreset_key_success = self.errors.on(:password_reset_key).nil? ? true : false 
    end
    send_forgot_password
  end
  
  def has_forgotten_password?
    !self.password_reset_key.nil?
  end
  
  def clear_forgot_password!
    self.password_reset_key = nil
    self.save
  end
  
  def send_activation_notification
    deliver_email(:activation_notification, :subject => "Welcome to Merbunity. ")
  end

  def send_signup_notification
    deliver_email(:signup_notification, :subject => "Welcome to Merbunity.  Please activate your account.")
  end

  def send_forgot_password
    deliver_email(:forgot_password, :subject => "Request to change your password")
  end

  def deliver_email(action, params)
    from = "info@merbunity.com"
    PersonMailer.dispatch_and_deliver(action, params.merge(:from => from, :to => self.email), :person => self)
  end
    
end
end