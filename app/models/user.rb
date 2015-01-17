class User < ActiveRecord::Base
  acts_as_taggable_on :skills
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  # token authentication https://github.com/gonzalo-bulnes/simple_token_authentication
  acts_as_token_authenticatable


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, 
    styles: {
      thumb: '75x75#', #iphone thumbnail
      web: '300x300#', #web index pages
    },
    convert_options: {
      thumb: '-quality 75 -strip',
      web: '-quality 75 -strip',
    }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  #has_many :devices

  #before_destroy :remove_user_from_mailchimp

  # validates_format_of :name, :with => /\A[a-zA-Z0-9_]{2,30}\Z/
  # validates :name, presence: true,
  #                  uniqueness: { case_sensitive: false }


  #has_many :meetings,  :foreign_key => 'creator_id'
  # belongs to account
  # has many messages
  # has many patients?

  # http://rails-bestpractices.com/posts/4-add-model-virtual-attribute
  def full_name
    [first_name, last_name].join(' ')
  end

  def full_name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def avatar_url
      avatar.url(:thumb)
  end

  def self.all_except(user)
    where.not(id: user)
  end

  def set_default_role
    self.role ||= :user
  end

  # Override Devise::Confirmable#after_confirmation
  def after_confirmation
    #add_user_to_mailchimp
  end

  # wildcard string match on name field with 3 chars or more
  def self.search(search)
    if search and search.length > 2
      wildcard_search = "%#{search}%"

      where("name ILIKE :search", search: wildcard_search).take(5)
    end
  end

  # override Devise method
  # no password is required when the account is created; validate password when the user sets one
  validates_confirmation_of :password
  def password_required?
    if !persisted?
      !(password != "")
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  private

  def add_user_to_mailchimp
    mailchimp = Gibbon::API.new
    result = mailchimp.lists.subscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email => {:email => self.email},
      :double_optin => false,
      :update_existing => true,
      :send_welcome => true
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp subscribe failed for #{self.email}: " + e.message)
  end


  def remove_user_from_mailchimp
    mailchimp = Gibbon::API.new
    result = mailchimp.lists.unsubscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email => {:email => self.email},
      :delete_member => true,
      :send_goodbye => false,
      :send_notify => true
      })
    Rails.logger.info("Unsubscribed #{self.email} from MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp unsubscribe failed for #{self.email}: " + e.message)
  end



end