class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, length: { minimum: 8 }
  
  has_one :presenter
  has_one :customer
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
end
