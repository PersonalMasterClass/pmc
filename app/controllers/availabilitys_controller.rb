class AvailabilitysController < ApplicationController
	
	def index
		@availabilitys = Availability.where(presenter: current_user.presenter).find_each
	end
	# form
	def new 
	end

	def show
	end

	# submit form
	def create
	end

end
