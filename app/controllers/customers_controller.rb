class CustomersController < ApplicationController
	before_filter :has_access?, :only => [:show]
  before_filter :is_customer?, :only => [:index]

  def index
    @customer = current_user.customer
  	@search_params = params();
  	@upcoming = Booking.upcoming(current_user) 
  	@bookings = Booking.where(shared: true)
	end

	def show
		@customer = Customer.find(params[:id])
		@user = @customer.user
	end

  def edit  
    @customer_id = current_user.customer
    @customer = Customer.find(@customer_id)
  end


  def update
    @customer = current_user.customer
    @customer.school_info = SchoolInfo.find(params[:school_id])
    if @customer.update(customer_update_params)
      redirect_to root_url
    else
      render 'edit'
    end
  end

  private
  def customer_update_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :vit_number, :department, :contact_title, 
                                       :school_id)

  end

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