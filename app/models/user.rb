class User < ActiveRecord::Base
  after_create :send_call_to_action_notification
  after_create :send_biannual_update_notification
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, length: { minimum: 8 }
  
  has_one :presenter, inverse_of: :user
  has_one :customer, inverse_of: :user
  has_many :notifications

  accepts_nested_attributes_for :presenter
  accepts_nested_attributes_for :customer

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
         
  enum user_type: [:customer, :presenter, :admin]
  enum status: [:pending, :approved, :suspended]

  def self.unapproved_customers
    User.where('user_type= ? AND status= ?', 0, 0)
  end

  def self.unapproved_presenters
    User.where('user_type= ? AND status= ?', 1, 0)
  end

  def self.suspended_customers
    User.where('user_type= ? AND status= ?', 0, 2)
  end

  def self.suspended_presenters
    User.where('user_type= ? AND status= ?', 1, 2)
  end

  # return a presenter or customer
  # returns nil of user is an admin
  def self.check_user(user)
    if user.presenter?
      return user.presenter
    elsif user.customer?
      return user.customer
    else
      return nil
    end
    return false
  end

  def display_notifications
    return self.notifications.where(is_read: :false).limit(5).order(created_at: :desc)
  end

  # get all the invoices for user from Xero
  def invoices
    return Xero.get_invoices(self)
  end

  
  private

  def send_call_to_action_notification
    Resque.enqueue_in 1.day, ReminderNotification, self.id
  end

  def send_biannual_update_notification
    Resque.enqueue_in 6.months, BiannualUpdate, self.id
  end
end
