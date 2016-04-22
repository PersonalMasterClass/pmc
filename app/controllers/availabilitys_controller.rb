class AvailabilitysController < ApplicationController 
	def index
		@availabilitys = Availability.where(presenter: current_user.presenter)
		# .find_each
	end
	# form
	def new 
		@availability = Availability.new(presenter: current_user.presenter) 
	end

	def show
	end

	# submit form
	def create
		# redirect_to action: 'index'

		availability = Availability.new
		availability.start_time = set_time(params['start_time'])
		availability.end_time = set_time(params['end_time'])

		render json: params['aval_days']
	end


	private
	# def availability_params
 #      params.require(:availability).permit(:day_val, :start_time, :end_time)
 #    end
 	def set_time(time_str)
 		x = time_str.split(':')
 		return x[0].to_i * 60 + x[1].to_i
 	end
  def set_day(daysArray)
  	dat = 0	

	end
	def day_arr

	end
end
