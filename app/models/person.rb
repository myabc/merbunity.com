require 'digest/sha1'
begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue 
  nil
end
class Person < DataMapper::Base
  
  include AuthenticatedSystem::Model
  include Merbunity::Permissions::User
  
  attr_accessor :password, :password_confirmation
  
  property :login,                      :string
  property :email,                      :string
  property :crypted_password,           :string
  property :salt,                       :string
  property :activation_code,            :string
  property :activated_at,               :datetime
  property :remember_token_expires_at,  :datetime
  property :remember_token,             :string
  property :created_at,                 :datetime
  property :updated_at,                 :datetime
  property :publisher_since,            :datetime
  property :admin_since,                :datetime
  property :published_item_count,       :integer,   :default => 0
  
  validates_length_of         :login,                   :within => 3..40
  validates_uniqueness_of     :login
  validates_presence_of       :email
  validates_format_of         :email,                   :with => :email_address
  validates_length_of         :email,                   :within => 3..100
  validates_uniqueness_of     :email
  validates_presence_of       :password,                :if => proc {password_required?}
  validates_presence_of       :password_confirmation,   :if => proc {password_required?}
  validates_length_of         :password,                :within => 4..40, :if => proc {password_required?}
  validates_confirmation_of   :password,                :if => proc{|m| !m.password.nil?}
    
  before_save :encrypt_password
  before_create :ensure_defaults # Should not be required :(
  before_create :make_activation_code
  after_create :send_signup_notification
  
  has_many :news_items, :foreign_key => "owner_id"
  
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
    @login = value.downcase unless value.nil?
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
  property :password_reset_key, :string, :writer => :protected
  validates_uniqueness_of :password_reset_key, :if => Proc.new{|m| !m.password_reset_key.nil?}
  
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