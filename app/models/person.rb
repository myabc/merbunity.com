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
  # validates_format_of         :email,                   :as => :email_address
  validates_length_of         :email,                   :within => 3..100
  validates_uniqueness_of     :email
  validates_presence_of       :password,                :if => proc {password_required?}
  validates_presence_of       :password_confirmation,   :if => proc {password_required?}
  validates_length_of         :password,                :within => 4..40, :if => proc {password_required?}
  validates_confirmation_of   :password,                :groups => :create
    
  before_save :encrypt_password
  before_create :ensure_defaults # Should not be required :(
  before_create :make_activation_code
  after_create :send_signup_notification
  
  has_many :news_items, :foreign_key => "owner_id"
  
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
    
  
  EMAIL_FROM = "info@merbunity.com"
  SIGNUP_MAIL_SUBJECT = "Welcome to Merbunity.  Please activate your account."
  ACTIVATE_MAIL_SUBJECT = "Welcome to Merbunity"
  
  # Activates the person in the database
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    self.save
    
    # send mail for activation
    PersonMailer.dispatch_and_deliver(  :activation_notification,
                                  {   :from => Person::EMAIL_FROM,
                                      :to   => self.email,
                                      :subject => Person::ACTIVATE_MAIL_SUBJECT },

                                      :person => self )

  end
  
  def send_signup_notification
    PersonMailer.dispatch_and_deliver(
        :signup_notification,
      { :from => Person::EMAIL_FROM,
        :to  => self.email,
        :subject => Person::SIGNUP_MAIL_SUBJECT },
        :person => self        
    )
  end
  


  
end