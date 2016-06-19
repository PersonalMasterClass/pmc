class Subject < ActiveRecord::Base
	# Associations
	has_and_belongs_to_many :presenters
	has_and_belongs_to_many :customers
	has_many :bookings, inverse_of: :subject

	# Validations
	validates :name, presence: true

	# Return a presenter's subjects
	def self.by_presenter(presenter)
		return presenter.subjects
	end
end
