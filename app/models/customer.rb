class Customer < ActiveRecord::Base
  has_many :booked_customers
  has_many :bookings, through: :booked_customers

	belongs_to :school_info
	validates :first_name, :last_name, :phone_number,
						:vit_number, :department, :contact_title, presence: true


end
