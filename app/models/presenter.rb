class Presenter < ActiveRecord::Base
	belongs_to :school_info
  has_one :presenter_profile, dependent: :destroy
  has_many :availabilitys
  has_and_belongs_to_many :subjects
  has_many :bids
  has_many :bookings, through: :bids

	validates :first_name, :last_name, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validates :phone_number, format: /\A^(?:\+?61|0)[2-4578](?:[ -]?[0-9]){8}$\Z/

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

  def profile_picture_path
    if self.presenter_profile.nil?
      return 'default-user-display.png'
    else
      if Rails.env.development? || Rails.env.test?
        return self.presenter_profile.picture.url
      else
        return self.presenter_profile.picture.remote_url
      end
    end
  end
end
