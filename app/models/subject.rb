class Subject < ActiveRecord::Base
	validates :name, presence: true
	has_and_belongs_to_many :presenters
	has_many :bookings, inverse_of: :booking

	def self.by_presenter(presenter)
		return presenter.subjects
	end
end
