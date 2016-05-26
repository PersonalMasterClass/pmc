class Customer < ActiveRecord::Base
  has_many :booked_customers
  has_many :bookings, through: :booked_customers

	belongs_to :school_info
  belongs_to :user, inverse_of: :customer
	validates :first_name, :last_name, :school_info, :department, :contact_title, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validate :vit_number_must_be_valid
  validates :phone_number, format: /\A^(?:\+?61|0)[2-4578](?:[ -]?[0-9]){8}$\Z/, presence: true

  def vit_number_must_be_valid
    unless VitValidation.check_vit(first_name, last_name, vit_number)
      errors.add(:vit_number, "could not be found on the VIT register.")
    end
  end

end
