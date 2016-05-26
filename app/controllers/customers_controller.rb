class CustomersController < ApplicationController
	before_filter :has_access, :only => [:show]

  def index
    @customer = current_user.customer
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
      render 'index'
    else
      render 'edit'
    end
  end

  private
  def customer_update_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :vit_number, :department, :contact_title, 
                                       :school_id)

  end

    def has_access
      redirect_to root_url unless (current_user.user_type == 'admin' || current_user.customer == Customer.find(params[:id]))
    end
end
