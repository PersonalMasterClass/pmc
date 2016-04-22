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
		availability = Availability.new(availability_params)
		availability.start_time = set_time(params['start_time'])
		availability.end_time = set_time(params['end_time'])
		availability.presenter = current_user.presenter
		if availability.save
			redirect_to presenter_availabilitys_path
		else
			render :new
		end
	end

	def destroy
		# if @availability.presenter == current_user.presenter || current_user == admin
			@availability = Availability.find(params[:id])
			@availability.destroy
		# end
		redirect_to presenter_availabilitys_path
	end

	private
	def availability_params
      params.require(:availability).permit(:monday, :tuesday, :wednesday, 
      	:thursday, :friday, :saturday, :sunday, :start_time, :end_time)
  end
  
  # convert the string passed from the post request to an int value of 
  # minutes past midnight. 
  # eg 1am is passed from the post request as 01:00 and converted to 60
 	def set_time(time_str)
 		x = time_str.split(':')
 		return x[0].to_i * 60 + x[1].to_i
 	end
  
end
