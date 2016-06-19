class BookedCustomer < ActiveRecord::Base

	# Associations
  belongs_to :customer 
  belongs_to :booking

  # Validations
  validates :number_students, :numericality => { :only_integer => true, :greater_than => 0}
end
