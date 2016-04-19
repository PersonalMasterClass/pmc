class Presenter < ActiveRecord::Base
	belongs_to :school_info
  has_one :presenter_profile, dependent: :destroy
  has_many :availabilitys
  has_and_belongs_to_many :subjects
  has_many :bids
  has_many :bookings, through: :bids

	validates :first_name, :last_name, :phone_number,
						:vit_number, presence: true

  # Retrieve user from presenter
  def get_user
  	users = User.unapproved_presenters
  	users.each do |user|
  		if self == user.presenter
  			return user
  		end
  	end
  	return false
  end
end
