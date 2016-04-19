class Booking < ActiveRecord::Base
  has_many :booked_customers
  has_many :customers, through: :booked_customers
  belongs_to :chosen_presenter, class_name: "Presenter"
  has_many :bids
  has_many :presenters, through: :bids

end
