class CustomersController < ApplicationController
	before_filter :has_access, :only => [:show]

  def index
	end

	def show
		@customer = Customer.find(params[:id])
		@user = @customer.get_user
	end

  private
    def has_access
      redirect_to root_url unless (current_user.user_type == 'admin' || current_user.customer == Customer.find(params[:id]))
    end
end
