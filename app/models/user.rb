class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one :presenter
  has_one :customer
  accepts_nested_attributes_for :presenter
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
