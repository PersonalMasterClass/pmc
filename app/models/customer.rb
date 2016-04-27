class Customer < ActiveRecord::Base
  has_many :booked_customers
  has_many :bookings, through: :booked_customers

	belongs_to :school_info

	validates :first_name, :last_name, :school_info, :department, :contact_title, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validate :vit_number_must_be_valid
  validates :phone_number, format: /\A^(?:\+?61|0)[2-4578](?:[ -]?[0-9]){8}$\Z/, presence: true
  # Retrieve user from presenter
  def get_user
  	users = User.all
  	users.each do |user|
  		if self == user.customer
  			return user
  		end
  	end
  	return false
  end

  def vit_number_must_be_valid
    unless VitValidation.new.check_vit(first_name, last_name, vit_number)
      errors.add(:vit_number, "could not be found on the vit register.")
    end
  end

end
