class CustomersController < ApplicationController
	before_filter :has_access, :only => [:show]

  def index
  	@search_params = params();
  	@upcoming = Booking.upcoming(current_user) 
  	@bookings = Booking.where(shared: true)
	end

	def show
		@customer = Customer.find(params[:id])
		@user = @customer.user
	end

  private
    def has_access
      redirect_to root_url unless (current_user.user_type == 'admin' || current_user.customer == Customer.find(params[:id]))
    end
end
