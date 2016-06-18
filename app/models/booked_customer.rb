class BookedCustomer < ActiveRecord::Base
  belongs_to :customer 
  belongs_to :booking

  validates :number_students, :numericality => { :only_integer => true, :greater_than => 0}
end
