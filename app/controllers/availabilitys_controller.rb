class AvailabilitysController < ApplicationController
	def index
		@availabilitys = Availability.find_by presenter: current_user.presenter
	end
	# form
	def new 
	end

	# submit form
	def create
	end

end
