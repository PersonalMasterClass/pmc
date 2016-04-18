class Subject < ActiveRecord::Base
	validates :name, presence: true
	has_and_belongs_to_many :presenters
	has_many :bookings
end
