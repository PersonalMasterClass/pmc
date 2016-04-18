class Booking < ActiveRecord::Base
  has_many :booked_customers
  has_many :customers, through: :booked_customers
  has_one :booking
end
