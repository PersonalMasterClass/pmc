class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_one :presenter
  accepts_nested_attributes_for :presenter
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
         
  enum user_type: [:customer, :presenter, :admin]
  enum status: [:pending, :approved, :suspended]
end
