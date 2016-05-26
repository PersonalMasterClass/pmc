class CustomersController < ApplicationController
	before_filter :has_access?, :only => [:show]
  before_filter :is_customer?, :only => [:index]

  def index
  	@search_params = params();
  	@upcoming = Booking.upcoming(current_user) 
  	@bookings = Booking.suggested(current_user)
    @joined_bookings = Booking.joined_bookings(current_user.customer)
	end

	def show
		@customer = Customer.find(params[:id])
		@user = @customer.user
	end

  private
    def has_access?
      redirect_to root_url unless (current_user.user_type == 'admin' || current_user.customer == Customer.find(params[:id]))
    end

    def is_customer?
      if !current_user
        redirect_to root_url
      elsif !current_user.customer?
        redirect_to root_url
      end
    end
end
