class AvailabilitysController < ApplicationController
	def index
		@availabilitys = Availability.where(presenter: current_user.presenter).find_each
	end
	# form
	def new 
		@availability = Availability.new(presenter: current_user.presenter) 
	end

	def show
	end

	# submit form
	def create
		params
	end
	private
	def availability_params
      params.require(:availability).permit(:day_val, :start_time, :end_time)
    end

end
