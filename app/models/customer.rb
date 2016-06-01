class Customer < ActiveRecord::Base
  has_many :booked_customers
  has_many :bookings, through: :booked_customers
  has_and_belongs_to_many :subjects
  has_many :created_bookings, class_name: "Booking"
	belongs_to :school_info
  belongs_to :user, inverse_of: :customer
	validates :first_name, :last_name, :school_info, :department, :contact_title, presence: true
  validates :vit_number, format: /\A^\d{6}$\Z/
  validate :vit_number_must_be_valid
  validates :phone_number, format: /\A^(?:\+?61|0)[2-4578](?:[ -]?[0-9]){8}$\Z/, presence: true

  # after_create :save_to_xero
  # after_update :update_xero

  def vit_number_must_be_valid
    unless VitValidation.check_vit(first_name, last_name, vit_number)
      errors.add(:vit_number, "could not be found on the vit register.")
    end
  end

  # Removes cancels all upcoming bookings for a customer, and removes customer from all joined bookings. 
  def cancel_upcoming_bookings()
    created_bookings = Booking.upcoming(self.user)
    #remove created bookings
      #send notifications
    created_bookings.each do |booking|
      Notification.canceled_booking(booking, "/bookings/#{booking}")
      booking.destroy
    end 
    #remove shared bookings
    shared_bookings = Booking.joined_bookings(self)
    
    shared_bookings.each do |booking|
      #send notification to owner
      booking.customers.delete(self)
      Notification.send_message(booking.creator.user, "Another school has been removed from your booking", "/bookings/#{booking}")
    end
  end

  def save_to_xero
    Xero.add_school_account(self)
  end

  def update_xero
    Xero.update_school_account(self)
  end

end
